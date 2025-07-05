import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/drawing_canvas.dart';
import 'package:flutter_application_1/services/gemini_service.dart'; // Raporlama için

class DrawingTestScreen extends StatefulWidget {
  const DrawingTestScreen({super.key});

  @override
  State<DrawingTestScreen> createState() => _DrawingTestScreenState();
}

class _DrawingTestScreenState extends State<DrawingTestScreen> {
  // DrawingCanvas'ın state'ine erişmek için GlobalKey kullanıyoruz.
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey();
  final GeminiService _geminiService = GeminiService();

  // Her bir test için kaydedilen çizim noktalarını tutacak harita
  // Key: test adı (örn. 'Saat', 'Spiral'), Value: List<DrawingPoint>
  final Map<String, List<DrawingPoint>> _recordedDrawingData = {};

  int _currentTestIndex = 0; // 0: saat, 1: spiral, 2: meander, 3: el yazısı

  final List<Map<String, String>> _testInstructions = [
    {'key': 'clock', 'title': 'Saat Çizimi Testi', 'instruction': 'Şimdi ekrana saat 10\'u 10 geçeyi gösteren bir saat çizin.'},
    {'key': 'spiral', 'title': 'Spiral Çizimi Testi', 'instruction': 'Ekranda beliren hedef spiralin üzerine veya yanına bir spiral çizin.'},
    {'key': 'meander', 'title': 'Meander Çizimi Testi', 'instruction': 'Ekranda beliren meander (dalgalı çizgi) desenini kopyalayın.'},
    {'key': 'handwriting', 'title': 'El Yazısı Testi', 'instruction': 'Lütfen "Yarın hava güneşli olacak." cümlesini buraya yazın.'},
  ];

  String get _currentTestKey => _testInstructions[_currentTestIndex]['key']!;
  String get _currentTestTitle => _testInstructions[_currentTestIndex]['title']!;
  String get _currentTestInstruction => _testInstructions[_currentTestIndex]['instruction']!;

  bool _isLoading = false; // Yükleme durumu

  /// Mevcut çizim testinin verilerini kaydeder.
  void _saveCurrentDrawing() {
    // GlobalKey aracılığıyla DrawingCanvasState'e eriş ve verileri al.
    final List<DrawingPoint>? currentPoints = _canvasKey.currentState?.getAllDrawingPoints();

    if (currentPoints != null && currentPoints.isNotEmpty) {
      _recordedDrawingData[_currentTestKey] = currentPoints;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_currentTestTitle} verileri kaydedildi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiç çizim verisi bulunamadı!')),
      );
    }
  }

  /// Sonraki teste geçer veya testleri bitirir.
  Future<void> _nextTest() async {
    // Önce mevcut çizimi kaydet
    _saveCurrentDrawing();

    // Tuvali temizle
    _canvasKey.currentState?.clearCanvas();

    if (_currentTestIndex < _testInstructions.length - 1) {
      setState(() {
        _currentTestIndex++;
      });
    } else {
      // Tüm testler tamamlandı, değerlendirme aşamasına geç.
      await _finalizeDrawingTests();
    }
  }

  /// Tüm çizim testleri bittiğinde genel bir değerlendirme yapar.
  Future<void> _finalizeDrawingTests() async {
    setState(() {
      _isLoading = true;
    });

    String drawingSummary = 'Çizim Testleri Özeti:\n';
    _recordedDrawingData.forEach((key, value) {
      drawingSummary += '${_testInstructions.firstWhere((element) => element['key'] == key)['title']}: ${value.length} nokta kaydedildi.\n';
      // Gerçek uygulamada burada ML modeline gönderme veya daha detaylı ön işleme yapılır.
      // Örneğin: _mlService.analyzeDrawing(value);
      // Şimdilik sadece nokta sayısını özetliyoruz.
    });
    drawingSummary += '\nDetaylı analiz için bu ham veriler ML modeline gönderilmelidir.';

    final prompt = '''
Aşağıdaki çizim ve el yazısı testi verileri özetini inceleyerek genel görsel-motor ve motor beceriler hakkında bir değerlendirme yap. 
Kesin tanı koyma, sadece gözlemlerini belirt. Kullanıcının her test için kaydettiği nokta sayıları: $drawingSummary
''';
    final evaluation = await _geminiService.askGemini(prompt);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return; // widget hala ağaçtaysa devam et
    Navigator.pop(context); // Test ekranından çık
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çizim Testi Değerlendirmesi'),
        content: SingleChildScrollView(child: Text(evaluation)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTestTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _currentTestInstruction,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: DrawingCanvas(
                    key: _canvasKey, // DrawingCanvasState'e erişmek için anahtar
                    // Burada spiral, meander için arka plan resmi eklenebilir.
                    // Örneğin:
                    // child: _currentTestKey == 'spiral'
                    //     ? Image.asset('assets/images/spiral_template.png', fit: BoxFit.contain)
                    //     : _currentTestKey == 'meander'
                    //         ? Image.asset('assets/images/meander_template.png', fit: BoxFit.contain)
                    //         : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _saveCurrentDrawing, // Sadece kaydetme butonu
                        child: const Text('Çizimi Kaydet'),
                      ),
                      ElevatedButton(
                        onPressed: _nextTest, // Sonraki teste geç veya bitir
                        child: Text(_currentTestIndex < _testInstructions.length - 1 ? 'Sonraki Test' : 'Testleri Bitir ve Değerlendir'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}