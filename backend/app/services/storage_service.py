"""
Storage service for medical documents (prescriptions, lab reports, discharge summaries, etc.).
Provides local persistent disk storage with zero external dependencies and zero recurring cost,
with optional fallback support for Cloudflare R2 / AWS S3 and legacy Supabase Storage.
"""
import asyncio
import os
import re
import uuid
from pathlib import Path
from typing import Optional, Tuple

from fastapi import HTTPException
from app.config import get_settings


class StorageService:
    def __init__(self) -> None:
        self.settings = get_settings()
        self.upload_dir = Path(self.settings.upload_dir).resolve()
        self.upload_dir.mkdir(parents=True, exist_ok=True)

    def _sanitize_filename(self, filename: str) -> str:
        name = Path(filename).name
        # Keep alphanumeric, dot, underscore, dash
        clean = re.sub(r"[^a-zA-Z0-9._-]", "_", name)
        return clean or "document"

    async def save_file(
        self,
        user_id: uuid.UUID,
        filename: str,
        contents: bytes,
        mime_type: str,
    ) -> Tuple[str, str]:
        """
        Saves file bytes according to configured storage_backend.
        Returns: (storage_path, public_url)
        """
        backend = (self.settings.storage_backend or "local").lower()

        if backend == "supabase" and self.settings.supabase_url and self.settings.supabase_service_key:
            return await self._upload_to_supabase(user_id, filename, contents, mime_type)
        else:
            return await self._save_to_local(user_id, filename, contents, mime_type)

    async def delete_file(self, storage_path: str) -> None:
        """
        Deletes file from storage backend.
        """
        backend = (self.settings.storage_backend or "local").lower()

        if backend == "supabase" and self.settings.supabase_url and self.settings.supabase_service_key:
            await self._delete_from_supabase(storage_path)
        else:
            await self._delete_from_local(storage_path)

    async def _save_to_local(
        self,
        user_id: uuid.UUID,
        filename: str,
        contents: bytes,
        mime_type: str,
    ) -> Tuple[str, str]:
        safe_name = self._sanitize_filename(filename)
        unique_prefix = uuid.uuid4().hex[:12]
        file_key = f"{unique_prefix}_{safe_name}"

        user_dir = self.upload_dir / str(user_id)
        user_dir.mkdir(parents=True, exist_ok=True)
        target_path = user_dir / file_key

        def _write() -> None:
            with open(target_path, "wb") as f:
                f.write(contents)

        await asyncio.to_thread(_write)

        storage_path = f"{user_id}/{file_key}"
        base_url = self.settings.api_public_base_url.rstrip("/")
        public_url = f"{base_url}/api/v1/documents/raw/{storage_path}"
        return storage_path, public_url

    async def _delete_from_local(self, storage_path: str) -> None:
        base_dir = self.upload_dir
        target_path = (self.upload_dir / storage_path).resolve()

        if not target_path.is_relative_to(base_dir):
            return

        def _remove() -> None:
            if target_path.exists() and target_path.is_file():
                try:
                    target_path.unlink()
                except OSError:
                    pass

        await asyncio.to_thread(_remove)

    def get_local_file_path(self, storage_path: str) -> Optional[Path]:
        """
        Validates that storage_path exists inside upload_dir with strict path traversal prevention.
        """
        base_dir = self.upload_dir
        target_path = (self.upload_dir / storage_path).resolve()

        if not target_path.is_relative_to(base_dir):
            return None

        if target_path.exists() and target_path.is_file():
            return target_path
        return None

    # ── Legacy Supabase Storage Fallback ──────────────────────────────────────
    async def _upload_to_supabase(
        self,
        user_id: uuid.UUID,
        filename: str,
        contents: bytes,
        mime_type: str,
    ) -> Tuple[str, str]:
        import httpx

        bucket = "documents"
        path = f"{user_id}/{uuid.uuid4()}_{self._sanitize_filename(filename)}"

        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"{self.settings.supabase_url}/storage/v1/object/{bucket}/{path}",
                headers={
                    "Authorization": f"Bearer {self.settings.supabase_service_key}",
                    "Content-Type": mime_type,
                },
                content=contents,
                timeout=30,
            )

        if resp.status_code not in (200, 201):
            raise HTTPException(
                status_code=502,
                detail=f"Supabase Storage upload failed: {resp.text}",
            )

        public_url = (
            f"{self.settings.supabase_url}/storage/v1/object/public/{bucket}/{path}"
        )
        return path, public_url

    async def _delete_from_supabase(self, storage_path: str) -> None:
        import httpx

        bucket = "documents"
        async with httpx.AsyncClient() as client:
            await client.delete(
                f"{self.settings.supabase_url}/storage/v1/object/{bucket}/{storage_path}",
                headers={"Authorization": f"Bearer {self.settings.supabase_service_key}"},
                timeout=10,
            )


# Cached singleton
_storage_service: Optional[StorageService] = None


def get_storage_service() -> StorageService:
    global _storage_service
    if _storage_service is None:
        _storage_service = StorageService()
    return _storage_service
