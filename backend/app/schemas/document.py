import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class DocumentResponse(BaseModel):
    id: uuid.UUID
    file_name: str
    file_type: str
    mime_type: str
    file_size_bytes: int
    public_url: Optional[str] = None
    uploaded_at: datetime

    model_config = {"from_attributes": True}
