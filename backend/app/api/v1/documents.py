"""
Documents endpoints: upload, list, delete.
"""
import uuid

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.document import Document
from app.models.user import User
from app.schemas.scan_event import DocumentResponse

router = APIRouter(prefix="/documents", tags=["Documents"])

ALLOWED_TYPES = {
    "prescription",
    "lab_report",
    "discharge_summary",
    "insurance_card",
    "other",
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

    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large — max 10 MB")

    # Upload to Supabase Storage
    storage_path, public_url = await _upload_to_supabase(
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

    # Remove from Supabase Storage
    await _delete_from_supabase(doc.storage_path)

    await db.delete(doc)
    return None


# ── Supabase Storage helpers ───────────────────────────────────────────────────

async def _upload_to_supabase(
    user_id: uuid.UUID,
    filename: str,
    contents: bytes,
    mime_type: str,
) -> tuple[str, str]:
    """
    Upload file bytes to Supabase Storage bucket 'documents'.
    Returns (storage_path, public_url).
    """
    import httpx
    from app.config import get_settings

    settings = get_settings()
    bucket = "documents"
    path = f"{user_id}/{uuid.uuid4()}_{filename}"

    async with httpx.AsyncClient() as client:
        resp = await client.post(
            f"{settings.supabase_url}/storage/v1/object/{bucket}/{path}",
            headers={
                "Authorization": f"Bearer {settings.supabase_service_key}",
                "Content-Type": mime_type,
            },
            content=contents,
            timeout=30,
        )

    if resp.status_code not in (200, 201):
        raise HTTPException(status_code=502, detail=f"Supabase Storage upload failed: {resp.text}")

    public_url = (
        f"{settings.supabase_url}/storage/v1/object/public/{bucket}/{path}"
    )
    return path, public_url


async def _delete_from_supabase(storage_path: str) -> None:
    import httpx
    from app.config import get_settings

    settings = get_settings()
    bucket = "documents"

    async with httpx.AsyncClient() as client:
        await client.delete(
            f"{settings.supabase_url}/storage/v1/object/{bucket}/{storage_path}",
            headers={"Authorization": f"Bearer {settings.supabase_service_key}"},
            timeout=10,
        )
