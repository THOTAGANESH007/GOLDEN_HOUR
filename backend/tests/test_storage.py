"""
Unit tests for StorageService and Document endpoints.
"""
import asyncio
import os
import shutil
import tempfile
import unittest
import uuid
from pathlib import Path

from app.services.storage_service import StorageService


class TestStorageService(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.service = StorageService()
        self.service.upload_dir = Path(self.temp_dir)
        self.user_id = uuid.uuid4()

    def tearDown(self):
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    async def test_save_and_retrieve_local_file(self):
        content = b"PDF dummy content"
        storage_path, public_url = await self.service.save_file(
            user_id=self.user_id,
            filename="my_prescription.pdf",
            contents=content,
            mime_type="application/pdf",
        )

        self.assertIn(str(self.user_id), storage_path)
        self.assertTrue(storage_path.endswith("my_prescription.pdf"))
        self.assertIn("/api/v1/documents/raw/", public_url)

        local_path = self.service.get_local_file_path(storage_path)
        self.assertIsNotNone(local_path)
        self.assertTrue(local_path.exists())
        self.assertEqual(local_path.read_bytes(), content)

    async def test_path_traversal_protection(self):
        # Attempt traversal outside upload_dir
        traversal_path = "../../etc/passwd"
        local_path = self.service.get_local_file_path(traversal_path)
        self.assertIsNone(local_path)

    async def test_delete_local_file(self):
        content = b"Lab report data"
        storage_path, _ = await self.service.save_file(
            user_id=self.user_id,
            filename="lab_test.pdf",
            contents=content,
            mime_type="application/pdf",
        )

        local_path = self.service.get_local_file_path(storage_path)
        self.assertIsNotNone(local_path)
        self.assertTrue(local_path.exists())

        await self.service.delete_file(storage_path)
        self.assertFalse(local_path.exists())
