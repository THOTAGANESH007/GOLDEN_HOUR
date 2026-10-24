"""
Documents endpoints: upload, list, delete, and secure streaming.
"""
import uuid

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import FileResponse, RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.document import Document
from app.models.user import User
from app.schemas.scan_event import DocumentResponse
from app.services.storage_service import get_storage_service

router = APIRouter(prefix="/documents", tags=["Documents"])

ALLOWED_TYPES = {
    "prescription",
    "lab_report",
    "discharge_summary",
    "insurance_card",
    "other",
}
ALLOWED_EXTENSIONS = {".pdf", ".png", ".jpg", ".jpeg", ".webp"}
ALLOWED_MIME_TYPES = {
    "application/pdf",
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


@router.get("", response_model=list[DocumentResponse])
async def list_documents(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Document)
        .where(Document.user_id == current_user.id)
        .order_by(Document.uploaded_at.desc())
    )
    return result.scalars().all()


@router.post("/upload", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def upload_document(
    file: UploadFile = File(...),
    file_type: str = Form(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if file_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"file_type must be one of: {', '.join(ALLOWED_TYPES)}",
        )

    import os
    ext = os.path.splitext(file.filename or "")[1].lower()
    content_type = (file.content_type or "").lower()
    if ext not in ALLOWED_EXTENSIONS and content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Invalid file format. Only PDF documents and images (PNG, JPG, WEBP) are allowed.",
        )

    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large — max 10 MB")

    storage = get_storage_service()
    storage_path, public_url = await storage.save_file(
        user_id=current_user.id,
        filename=file.filename or "document",
        contents=contents,
        mime_type=file.content_type or "application/octet-stream",
    )

    doc = Document(
        user_id=current_user.id,
        file_name=file.filename or "document",
        file_type=file_type,
        mime_type=file.content_type or "application/octet-stream",
        file_size_bytes=len(contents),
        storage_path=storage_path,
        public_url=public_url,
    )
    db.add(doc)
    await db.flush()
    return doc


@router.delete("/{doc_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_document(
    doc_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Document).where(
            Document.id == doc_id, Document.user_id == current_user.id
        )
    )
    doc = result.scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    storage = get_storage_service()
    await storage.delete_file(doc.storage_path)

    await db.delete(doc)
    return None


@router.get("/raw/{storage_path:path}")
async def get_raw_document(
    storage_path: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Streams the raw document file directly with support for Range requests,
    enabling seamless display in mobile app CachedNetworkImage and PDF Viewers.
    """
    result = await db.execute(
        select(Document).where(Document.storage_path == storage_path)
    )
    doc = result.scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    if doc.public_url and (
        doc.public_url.startswith("https://") or doc.public_url.startswith("http://")
    ) and "/api/v1/documents/raw/" not in doc.public_url:
        return RedirectResponse(url=doc.public_url)

    storage = get_storage_service()
    file_path = storage.get_local_file_path(storage_path)
    if not file_path:
        raise HTTPException(status_code=404, detail="Document file not found on disk")

    return FileResponse(
        path=file_path,
        media_type=doc.mime_type,
        filename=doc.file_name,
    )


@router.get("/{doc_id}/raw")
async def get_document_raw_by_id(
    doc_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    """
    Convenience endpoint to stream raw document by its unique UUID.
    """
    result = await db.execute(select(Document).where(Document.id == doc_id))
    doc = result.scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    if doc.public_url and (
        doc.public_url.startswith("https://") or doc.public_url.startswith("http://")
    ) and "/api/v1/documents/raw/" not in doc.public_url:
        return RedirectResponse(url=doc.public_url)

    storage = get_storage_service()
    file_path = storage.get_local_file_path(doc.storage_path)
    if not file_path:
        raise HTTPException(status_code=404, detail="Document file not found on disk")

    return FileResponse(
        path=file_path,
        media_type=doc.mime_type,
        filename=doc.file_name,
    )
