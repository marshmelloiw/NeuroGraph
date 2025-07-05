from fastapi import FastAPI
from pydantic import BaseModel
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.schema import HumanMessage
import os
from dotenv import load_dotenv
from app.api import mmse
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()  # .env dosyasını oku

app = FastAPI()

# CORS ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Geliştirme için * kullanabilirsin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(mmse.router)


class UserInput(BaseModel):
    message: str

@app.post("/gemini")
def chat_with_gemini(user_input: UserInput):
    chat = ChatGoogleGenerativeAI(model="gemini-1.5-flash-8b-latest", google_api_key=os.getenv("GOOGLE_API_KEY"))
    response = chat([HumanMessage(content=user_input.message)])
    return {"response": response.content}
