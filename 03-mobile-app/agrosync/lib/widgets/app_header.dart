import 'package:flutter/material.dart';

import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/imagens.dart';

/// Quadradinho arredondado com emoji (logo do app).
class LogoTile extends StatelessWidget {
  const LogoTile({super.key, this.tamanho = 40, this.emoji = '🌱', this.claro = false});

  final double tamanho;
  final String emoji;

  /// true = fundo verde-claro (usado sobre fundo branco, como no login).
  final bool claro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: claro ? const Color(0xFFD1FAE5) : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(tamanho * 0.3),
        border: Border.all(
            color: claro ? const Color(0xFFA7F3D0) : Colors.white.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tamanho * 0.14),
        child: Image.asset(
          Imagens.logo.caminho, // coloque sua logo em assets/imagens/logo.png
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Text(emoji, style: TextStyle(fontSize: tamanho * 0.5)),
        ),
      ),
    );
  }
}

/// Cabeçalho verde fixo do app: logo, nome, subtítulo e botão "Guia".
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.onGuia});

  final VoidCallback onGuia;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.verdeEscuro, Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              const LogoTile(),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AgroSync',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text('CitizenTech • Agricultura Familiar',
                        style: TextStyle(color: AppTheme.menta, fontSize: 11.5)),
                  ],
                ),
              ),
              Material(
                color: Colors.black.withValues(alpha: 0.22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onGuia,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('❓', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 6),
                        Text('Guia',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
