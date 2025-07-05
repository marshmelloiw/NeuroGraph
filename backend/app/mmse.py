from fastapi import APIRouter
from pydantic import BaseModel
from langchain_google_genai import ChatGoogleGenerativeAI
import os
from dotenv import load_dotenv
from typing import Optional

load_dotenv()

router = APIRouter()

chat = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash-preview-image-generation",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)

class UserInput(BaseModel):
    input: str = "Merhaba"
    history: list = []  # Önceki konuşmaların tutulacağı alan
    image: Optional[str] = None  # Base64 görsel desteği

@router.post("/mmse")
def run_mmse(user_input: UserInput):
    prompt = "Lütfen bana bir görsel gönder. Görseli açıklamanı istiyorum. Sadece bir görsel üret ve gönder."
    result = chat.invoke(prompt)
    print("[DEBUG] Gemini'dan dönen result nesnesi:", result)
    response_text = result.content if hasattr(result, 'content') else str(result)
    response_image = None
    if hasattr(result, 'image') and result.image:
        response_image = result.image
    elif isinstance(result, dict) and 'image' in result:
        response_image = result['image']
    print("[DEBUG] Gemini yanıtı metin uzunluğu:", len(response_text))
    if response_image:
        print("[DEBUG] Gemini'dan görsel döndü (base64 uzunluğu):", len(response_image))
    else:
        print("[DEBUG] Gemini'dan görsel dönmedi.")
    return {"response": response_text, "image": response_image}
