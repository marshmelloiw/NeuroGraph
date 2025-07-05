import google.generativeai as genai # 'google.generativeai' olarak import ediyoruz
from dotenv import load_dotenv
import os

load_dotenv()

# API anahtarını yapılandırın.
# Yeni SDK'da 'genai.configure()' API anahtarını global olarak ayarlar.
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Modeli doğrudan genai.GenerativeModel ile oluşturun.
# Burada 'client' nesnesine ihtiyaç duymazsınız çünkü API anahtarı configure edildi.
model = genai.GenerativeModel('gemini-2.0-flash-001')

print("Gemini sohbetine hoş geldiniz! Çıkmak için 'çıkış' yazın.")

# Sohbet oturumunu başlatın.
chat = model.start_chat(history=[])

while True:
    user_input = input("Siz: ") # Kullanıcıdan input alın

    if user_input.lower() == 'çıkış':
        print("Sohbetten çıkılıyor. Hoşça kalın!")
        break # Döngüden çık

    try:
        # Kullanıcının mesajını chat oturumuna gönderin ve yanıtı alın.
        response = chat.send_message(user_input)

        # Modelin yanıtını yazdırın
        print("Gemini:", response.text)

    except Exception as e:
        print(f"Bir hata oluştu: {e}")
        print("Lütfen API anahtarınızın doğru olduğundan ve internet bağlantınızın olduğundan emin olun.")
        break