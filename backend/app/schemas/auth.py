from pydantic import BaseModel, field_validator
import re


class SendOTPRequest(BaseModel):
    phone: str       # E.164: +91XXXXXXXXXX
    consent_given: bool = False   # DPDPA checkbox

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        if not re.match(r"^\+\d{10,15}$", v):
            raise ValueError("Phone must be in E.164 format e.g. +91XXXXXXXXXX")
        return v


class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        if not re.match(r"^\+\d{10,15}$", v):
            raise ValueError("Phone must be in E.164 format e.g. +91XXXXXXXXXX")
        return v

    @field_validator("otp")
    @classmethod
    def validate_otp(cls, v: str) -> str:
        if not re.match(r"^\d{6}$", v):
            raise ValueError("OTP must be exactly 6 digits")
        return v


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    wizard_completed: bool = False


class RefreshRequest(BaseModel):
    refresh_token: str


class FCMTokenUpdate(BaseModel):
    fcm_token: str


class GoogleAuthRequest(BaseModel):
    id_token: str
    fcm_token: str | None = None
