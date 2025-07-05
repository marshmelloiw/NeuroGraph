from fastapi import APIRouter
from .mmse import router as mmse_router

router = APIRouter()
router.include_router(mmse_router)