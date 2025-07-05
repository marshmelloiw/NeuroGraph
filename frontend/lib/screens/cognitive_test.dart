import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/gemini_service.dart';
import 'package:uuid/uuid.dart';

class CognitiveTestScreen extends StatefulWidget {
  const CognitiveTestScreen({super.key});

  @override
  State<CognitiveTestScreen> createState() => _CognitiveTestScreenState();
}

class _CognitiveTestScreenState extends State<CognitiveTestScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final String _sessionId = const Uuid().v4();

  bool _isLoading = false;
  int _questionCount = 0;
  static const int _maxQuestions = 5;

  @override
  void initState() {
    super.initState();
    _loadInitialQuestion();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialQuestion() async {
    _setLoadingState(true, 'Bilişsel teste hoş geldiniz! İlk soru yükleniyor...');
    _addMessage('gemini', 'Bilişsel teste hoş geldiniz! İlk soru yükleniyor...');
    
    final prompt = 'Bana nöropsikolojik değerlendirme için basit bir genel oryantasyon sorusu sor. Sadece soruyu ver, ek açıklama yapma.';
    try {
      final response = await _geminiService.askGemini(prompt);
      _addMessage('gemini', response);
      setState(() {
        _questionCount++;
      });
    } catch (e) {
      _addMessage('gemini', 'Hata: İlk soru yüklenemedi. Lütfen internet bağlantınızı kontrol edin.');
      debugPrint('İlk soru yükleme hatası: $e');
    } finally {
      _setLoadingState(false);
      _scrollToBottom();
    }
  }

  Future<void> _submitAnswer() async {
    final userAnswer = _messageController.text.trim();
    if (userAnswer.isEmpty) {
      _showSnackBar('Lütfen bir cevap girin.');
      return;
    }

    _addMessage('user', userAnswer);
    _setLoadingState(true, 'Cevabınız değerlendiriliyor...');
    _messageController.clear();

    if (_questionCount >= _maxQuestions) {
      await _finalizeTest();
    } else {
      await _loadNextQuestion();
    }
    _scrollToBottom();
  }

  Future<void> _loadNextQuestion() async {
    final String lastQuestion = _messages[_messages.length - 2]['text']!;
    final String lastAnswer = _messages.last['text']!;
    
    final String nextPrompt = '''
Kullanıcı önceki soruya ("$lastQuestion") "$lastAnswer" cevabını verdi. 
Şimdi bana bilişsel alanlardan hafıza, dikkat, dil veya yargılama becerilerini test eden yeni bir soru sor. 
Sadece soruyu ver, başka bir açıklama yapma.
''';

    try {
      final response = await _geminiService.askGemini(nextPrompt);
      _addMessage('gemini', response);
      setState(() {
        _questionCount++;
      });
    } catch (e) {
      _addMessage('gemini', 'Hata: Yeni soru yüklenemedi. Lütfen internet bağlantınızı kontrol edin.');
      debugPrint('Sonraki soru yükleme hatası: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _finalizeTest() async {
    _setLoadingState(true, 'Test sonuçları değerlendiriliyor...');
    _addMessage('gemini', 'Test sonuçları değerlendiriliyor...');
    _scrollToBottom();

    String testSummary = 'Bilişsel Test Verileri:\n';
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i]['sender'] == 'gemini' && (i + 1 < _messages.length) && _messages[i + 1]['sender'] == 'user') {
        final question = _messages[i]['text'];
        final answer = _messages[i + 1]['text'];

        testSummary += 'Soru ${(_messages.indexOf(_messages[i]) ~/ 2) + 1}: $question\n';
        testSummary += 'Cevap ${(_messages.indexOf(_messages[i]) ~/ 2) + 1}: $answer\n\n';
      }
    }

    final prompt = '''
Aşağıdaki bilişsel test sorularını ve kullanıcının cevaplarını inceleyerek genel bilişsel durum hakkında kısa bir ön değerlendirme yap. 
Kesin tanı koyma, sadece gözlemlerini ve potansiyel güçlü/zayıf alanları belirt. 
Ayrıca, test edilen bilişsel alanları (örn. hafıza, dikkat, dil, oryantasyon, yargılama) vurgula.

Test Verileri:
$testSummary
''';
    try {
      final evaluation = await _geminiService.askGemini(prompt);
      _addMessage('gemini', 'Değerlendirme tamamlandı:\n$evaluation');
    } catch (e) {
      _addMessage('gemini', 'Hata: Değerlendirme alınamadı. Lütfen internet bağlantınızı kontrol edin.');
      debugPrint('Değerlendirme hatası: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  void _addMessage(String sender, String text) {
    setState(() {
      _messages.add({'sender': sender, 'text': text});
    });
  }

  void _setLoadingState(bool loading, [String? statusMessage]) {
    setState(() {
      _isLoading = loading;
      // İsteğe bağlı: loading mesajını kullanıcıya göstermek için
      // if (statusMessage != null && loading) {
      //   _messages.add({'sender': 'status', 'text': statusMessage});
      // }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Bilişsel Test',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/neuron_background.png'),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
          color: Color(0xFF1A1A2E),
        ),
        child: Column(
          children: <Widget>[
            // AppBar'ın altından başlaması için boşluk ekle
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final messageData = _messages[index];
                  final isUser = messageData['sender'] == 'user';
                  final isError = messageData['sender'] == 'error';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(12.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser 
                            ? const Color(0xFF6A0DAD)
                            : (isError ? Colors.red[700] : const Color(0xFF4A4A6A)),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        messageData['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.white70,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Sohbet giriş alanı ve gönder butonu
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A4A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cevabınızı buraya yazın',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: const Color(0xFF3A3A5A),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: (value) => _isLoading ? null : _submitAnswer(),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  FloatingActionButton(
                    onPressed: _isLoading ? null : _submitAnswer,
                    mini: true,
                    backgroundColor: const Color(0xFF6A0DAD),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Soru sayacı
            if (_questionCount <= _maxQuestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                child: Text(
                  'Tamamlanan Soru Sayısı: $_questionCount/$_maxQuestions',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}