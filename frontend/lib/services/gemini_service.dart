// lib/services/gemini_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  // BURAYA KENDİ GEMINI API ANAHTARINIZI EKLEYİN!
  // Google AI Studio'dan alabilirsiniz: https://aistudio.google.com/
  // Güvenlik için bu anahtarı production uygulamasında doğrudan burada tutmayın.
  // Bir arka uç sunucusu aracılığıyla kullanmanız önerilir.
  final String _apiKey = 'AIzaSyDYyzpRR-6odkx6Acik9X_VWmtwUz6Vkio'; // <-- Kendi API anahtarınızla değiştirin!

  // API base URL'i
  final String _apiBase = 'https://generativelanguage.googleapis.com/v1beta/models/';
  // Doğru model adını buraya girin (örneğin 'gemini-1.0-pro')
  // ListModels çağrısı yaparak veya Gemini dokümantasyonundan kontrol edin.
  final String _modelName = 'gemini-2.5-flash'; // <-- Gemini tarafından desteklenen doğru model adını buraya girin!

  Future<String> askGemini(String prompt) async {
    // API Anahtarı eksikse uyarı ver
    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.isEmpty) {
      return 'Hata: Gemini API anahtarı ayarlanmadı. Lütfen "lib/services/gemini_service.dart" dosyasını kontrol edin.';
    }

    final url = Uri.parse('$_apiBase$_modelName:generateContent?key=$_apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'contents': [
        {'parts': [
          {'text': prompt}
        ]}
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Gemini API yanıt yapısına göre ayıklama yapın.
        // Genellikle 'candidates' -> 'content' -> 'parts' -> 'text' içinde olur.
        if (data['candidates'] != null && data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        return 'Yanıt alınamadı veya boş geldi.';
      } else {
        print('Gemini API Hatası: ${response.statusCode} - ${response.body}');
        return 'API bağlantı hatası: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('İstek gönderme hatası: $e');
      return 'İstek gönderilirken bir hata oluştu: $e';
    }
  }

  // Debug için modelleri listeleyen geçici metod (kullanıma gerek yoksa silebilirsiniz)
  Future<void> listModels() async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.isEmpty) {
      print('Hata: Gemini API anahtarı ayarlanmadı.');
      return;
    }

    final url = Uri.parse('${_apiBase}?key=$_apiKey'); // ListModels için doğru URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Mevcut Gemini Modelleri:');
        print(json.decode(response.body)); // Tüm yanıtı yazdırın
      } else {
        print('Modelleri listelerken hata oluştu: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Modelleri listeleme isteği gönderme hatası: $e');
    }
  }
}