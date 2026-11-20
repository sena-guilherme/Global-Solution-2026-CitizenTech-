import 'package:flutter/material.dart';

import 'package:agrosync/pages/splash_page.dart';
import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/repositories/local_storage.dart';
import 'package:agrosync/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  ApiRepository.instance.init();
  runApp(const AgroSyncApp());
}

class AgroSyncApp extends StatefulWidget {
  const AgroSyncApp({super.key});

  @override
  State<AgroSyncApp> createState() => AgroSyncAppState();

  static AgroSyncAppState of(BuildContext context) =>
      context.findAncestorStateOfType<AgroSyncAppState>()!;
}

class AgroSyncAppState extends State<AgroSyncApp> {
  ThemeMode _themeMode = LocalStorage.instance.themeMode;
  double _textScale = LocalStorage.instance.textScale;
  String _fonte = LocalStorage.instance.fonte;

  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;
  String get fonte => _fonte;

  void setFonte(String fonte) {
    setState(() => _fonte = fonte);
    LocalStorage.instance.salvarFonte(fonte);
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    LocalStorage.instance.salvarTema(mode);
  }

  void setTextScale(double escala) {
    setState(() => _textScale = escala);
    LocalStorage.instance.salvarEscalaTexto(escala);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(fonte: _fonte),
      darkTheme: AppTheme.dark(fonte: _fonte),
      themeMode: _themeMode,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(_textScale)),
          child: SafeArea(
            child: content,
          ),
        );
      },
      home: const SplashPage(),
    );
  }
}