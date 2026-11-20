import 'package:flutter/material.dart';

import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/widgets/app_header.dart';
import 'package:agrosync/pages/home_page.dart';
import 'package:agrosync/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final destino =
        ApiRepository.instance.logado ? const HomePage() : const LoginPage();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => destino,
        transitionsBuilder: (_, anim, __, filho) =>
            FadeTransition(opacity: anim, child: filho),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF047857), Color(0xFF065F46), Color(0xFF0F2438)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoTile(tamanho: 76),
                const SizedBox(height: 28),
                const Text('AgroSync',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                  'Tecnologia inteligente para o pequeno produtor rural • CitizenTech',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.menta, fontSize: 13.5),
                ),
                const SizedBox(height: 36),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 2000),
                  builder: (context, valor, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 96,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: valor,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
