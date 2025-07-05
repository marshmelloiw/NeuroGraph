import 'package:flutter/material.dart';
import 'homePage.dart'; // Anasayfa için

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // Gerçek bir uygulamada burada Firebase Auth, kendi API'nız vb. kullanılacak.
    // Şimdilik basit bir kontrol ile geçiş yapıyoruz.
    if (_usernameController.text == 'testuser' && _passwordController.text == 'password') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş Başarılı!')),
      );
      // Giriş başarılıysa Anasayfaya yönlendir
      // pushReplacement kullanmak, geri tuşuyla giriş ekranına dönülmesini engeller.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Giriş başarısızsa hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz kullanıcı adı veya şifre!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroGraph Uygulamasına Hoş Geldiniz'),
        // Renkler main.dart'taki tema tarafından belirleniyor
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lütfen Giriş Yapın',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}