import 'package:flutter/material.dart';
import 'cognitive_test.dart'; // Bilişsel test ekranı
import 'drawing_test.dart'; // Çizim test ekranı
import 'audio_test_screen.dart'; // Sesli okuma test ekranı

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(); // Animasyonu bir kez başlat
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation = ColorTween(
      begin: const Color(0xFF4A148C).withOpacity(0.9),
      end: const Color(0xFF1A237E).withOpacity(0.8),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('NeuroGraph'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // color1 ve color2'nin null olup olmadığını kontrol et ve varsayılan değerler ata
          final Color gradientColor1 = _colorAnimation.value ?? Theme.of(context).colorScheme.primary;
          final Color gradientColor2 = _colorAnimation.value?.withOpacity(0.5) ?? Theme.of(context).colorScheme.tertiary;

          return Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/neuron_background.png'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                colors: [
                  gradientColor1.withOpacity(gradientColor1.opacity.clamp(0.0, 1.0)),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.6.clamp(0.0, 1.0)),
                  gradientColor2.withOpacity(gradientColor2.opacity.clamp(0.0, 1.0)),
                  Theme.of(context).colorScheme.surfaceTint.withOpacity(0.5.clamp(0.0, 1.0)),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Test Seçenekleri',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(3, 3),
                                ),
                              ],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildTestCard(
                        context,
                        icon: Icons.psychology_outlined,
                        title: 'Bilişsel Testi Başlat',
                        description: 'Hafıza, dikkat ve problem çözme becerilerini değerlendirin.',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CognitiveTestScreen()));
                        },
                        delay: 0.2,
                      ),
                      const SizedBox(height: 20),
                      _buildTestCard(
                        context,
                        icon: Icons.edit_outlined,
                        title: 'Çizim Testlerini Başlat',
                        description: 'Görsel-motor becerilerini ve el yazısını değerlendirin.',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawingTestScreen()));
                        },
                        delay: 0.4,
                      ),
                      const SizedBox(height: 20),
                      _buildTestCard( // Yeni okuma testi kartı
                        context,
                        icon: Icons.volume_up_outlined, // Sesli okuma için ikon
                        title: 'Sesli Okuma Testlerini Başlat',
                        description: 'Okuma akıcılığı, anlama ve dikkat becerilerini değerlendirin.',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadingTestScreen()));
                        },
                        delay: 0.6, // Diğer kartlardan sonra görünsün
                      ),
                      const SizedBox(height: 20),
                      _buildTestCard(
                        context,
                        icon: Icons.history_edu_outlined,
                        title: 'Geçmiş Raporları Görüntüle',
                        description: 'Daha önceki test sonuçlarına ve raporlara erişin.',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Geçmiş Raporlar Görüntülenecek (Yakında!)')),
                          );
                        },
                        delay: 0.8, // Daha sonra görünsün
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required double delay,
  }) {
    final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
    ));

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - delayedAnimation.value)),
          child: Opacity(
            opacity: delayedAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.9 + 0.1 * delayedAnimation.value,
              child: Card(
                elevation: 10 + (delayedAnimation.value * 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}