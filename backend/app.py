from flask import Flask, request, jsonify
from flask_cors import CORS # CORS hatasını önlemek için
from dotenv import load_dotenv
import os
import google.generativeai as genai

load_dotenv()

app = Flask(__name__)
CORS(app) # Tüm kökenlerden gelen isteklere izin verin (geliştirme için uygun, üretimde kısıtlanmalı)

# Gemini API'yi yapılandırın
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))
model = genai.GenerativeModel('gemini-2.0-flash-001')

# Sohbet geçmişini sunucu tarafında tutmak için basit bir sözlük.
# Gerçek bir uygulamada bu, veritabanı veya daha kalıcı bir depolama olmalıdır.
# Her kullanıcı için ayrı bir sohbet geçmişi tutmak için session ID kullanabiliriz.
chat_sessions = {}

@app.route('/chat', methods=['POST'])
def chat_endpoint():
    data = request.get_json()
    user_message = data.get('message')
    # Flutter uygulamasından bir session_id gönderilmesini bekleyelim
    session_id = data.get('session_id', 'default_session')

    if not user_message:
        return jsonify({"error": "Mesaj boş olamaz!"}), 400

    # Kullanıcının sohbet geçmişini al veya yeni bir tane başlat
    if session_id not in chat_sessions:
        chat_sessions[session_id] = model.start_chat(history=[])

    chat = chat_sessions[session_id]

    try:
        response = chat.send_message(user_message)
        model_response = response.text
        return jsonify({"response": model_response})
    except Exception as e:
        # Hata detaylarını loglayın, ancak kullanıcıya genel bir hata mesajı gönderin
        print(f"Gemini API hatası: {e}")
        return jsonify({"error": "Gemini API'den yanıt alınamadı. Lütfen daha sonra tekrar deneyin."}), 500

@app.route('/')
def home():
    return "Gemini Sohbet API'si çalışıyor!"

if __name__ == '__main__':
    # API'yi yerel ağda çalıştırın.
    # host='0.0.0.0' dışarıdan erişime izin verir (mobil cihazlar için önemli).
    # port=5000 varsayılan Flask portudur.
    app.run(host='0.0.0.0', port=5000, debug=True)