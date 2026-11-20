import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agrosync/models/alerta_model.dart';
import 'package:agrosync/models/area_model.dart';

/// Cores de superfície que mudam entre claro e escuro.
class Paleta {
  const Paleta({
    required this.fundo,
    required this.card,
    required this.borda,
    required this.texto,
    required this.mudo,
    required this.suave,
    required this.campo,
    required this.verdeSuave,
  });

  final Color fundo;
  final Color card;
  final Color borda;
  final Color texto;
  final Color mudo;
  final Color suave;
  final Color campo; 
  final Color verdeSuave;

  static const claro = Paleta(
    fundo: Color(0xFFF1F5F9),
    card: Colors.white,
    borda: Color(0xFFE2E8F0),
    texto: Color(0xFF0F172A),
    mudo: Color(0xFF64748B),
    suave: Color(0xFFF1F5F9),
    campo: Color(0xFFF8FAFC),
    verdeSuave: Color(0xFFD1FAE5),
  );

  static const escuro = Paleta(
    fundo: Color(0xFF0B1220),
    card: Color(0xFF131E31),
    borda: Color(0xFF22324D),
    texto: Color(0xFFE2E8F0),
    mudo: Color(0xFF94A3B8),
    suave: Color(0xFF1A263B),
    campo: Color(0xFF0F1A2B),
    verdeSuave: Color(0xFF064E3B),
  );

  static Paleta of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? escuro : claro;
}

class AppTheme {
  static const Color verde = Color(0xFF059669);
  static const Color verdeEscuro = Color(0xFF047857);
  static const Color verdeProfundo = Color(0xFF064E3B);
  static const Color menta = Color(0xFF6EE7B7);
  static const Color navy = Color(0xFF0F172A);
  static const Color azul = Color(0xFF3B82F6);
  static const Color laranja = Color(0xFFF59E0B);

  static String? familia(String chave) {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    switch (chave) {
      case 'serifada':
        return ios ? 'Georgia' : 'serif';
      case 'mono':
        return ios ? 'Courier' : 'monospace';
      default:
        return null; // padrão do sistema
    }
  }

  static ThemeData light({String fonte = 'padrao'}) =>
      _construir(Brightness.light, fonte);
  static ThemeData dark({String fonte = 'padrao'}) =>
      _construir(Brightness.dark, fonte);

  static ThemeData _construir(Brightness brilho, String fonte) {
    final p = brilho == Brightness.dark ? Paleta.escuro : Paleta.claro;
    final esquema = ColorScheme.fromSeed(seedColor: verde, brightness: brilho)
        .copyWith(
      primary: verde,
      onPrimary: Colors.white,
      surface: p.card,
      error: const Color(0xFFDC2626),
    );
    final bordaCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: p.borda),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: familia(fonte),
      colorScheme: esquema,
      scaffoldBackgroundColor: p.fundo,
      dividerColor: p.borda,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.borda),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: verdeEscuro,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.campo,
        hintStyle: TextStyle(color: p.mudo.withValues(alpha: 0.7)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: bordaCampo,
        enabledBorder: bordaCampo,
        focusedBorder: bordaCampo.copyWith(
            borderSide: const BorderSide(color: verde, width: 1.6)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: verde,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.texto,
          side: BorderSide(color: p.borda),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: p.borda),
        backgroundColor: p.card,
        selectedColor: verde.withValues(alpha: 0.15),
        labelStyle: TextStyle(color: p.texto, fontSize: 13),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.card,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final ativo = estados.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: ativo ? FontWeight.w800 : FontWeight.w500,
            color: ativo ? verde : p.mudo,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static Color corSeveridade(Severidade s) {
    switch (s) {
      case Severidade.critico:
        return const Color(0xFFDC2626);
      case Severidade.moderado:
        return const Color(0xFFD97706);
      case Severidade.normal:
        return verde;
    }
  }

  static Color corClassificacao(ClassificacaoUmidade c) {
    switch (c) {
      case ClassificacaoUmidade.critico:
        return const Color(0xFFDC2626);
      case ClassificacaoUmidade.moderado:
        return const Color(0xFFD97706);
      case ClassificacaoUmidade.normal:
        return verde;
      case ClassificacaoUmidade.excesso:
        return const Color(0xFF7C3AED);
    }
  }

  static Color corUmidade(double u) => corClassificacao(ClassificacaoUmidade.de(u));

  static String rotuloUmidade(double u) => ClassificacaoUmidade.de(u).rotulo;
}
