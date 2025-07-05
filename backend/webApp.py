from flask import Flask, render_template, request, jsonify, session
from dotenv import load_dotenv
import os
import google.generativeai as genai

load_dotenv()

app = Flask(__name__)
app.secret_key = os.urandom(24) # Oturum yönetimi için gizli anahtar

# Gemini API'yi yapılandırın
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))
model = genai.GenerativeModel('gemini-2.0-flash-001')

@app.route('/')
def index():
    # Uygulama açıldığında sohbet geçmişini sıfırla veya başlat
    session['chat_history'] = []
    return render_template('index.html')

@app.route('/send_message', methods=['POST'])
def send_message():
    user_message = request.json.get('message')
    if not user_message:
        return jsonify({"error": "Mesaj boş olamaz!"}), 400

    # Sohbet geçmişini oturumdan al
    chat_history = session.get('chat_history', [])

    # Sohbeti başlat veya devam ettir
    # history parametresi ile her istekte geçmişi modele iletiyoruz
    chat = model.start_chat(history=chat_history)

    try:
        response = chat.send_message(user_message)
        model_response = response.text

        # Yeni mesajı ve yanıtı geçmişe ekle
        chat_history.append({'role': 'user', 'parts': [user_message]})
        chat_history.append({'role': 'model', 'parts': [model_response]})
        session['chat_history'] = chat_history # Oturumu güncelle

        return jsonify({"response": model_response})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True) # Geliştirme için debug=True, üretimde False olmalı