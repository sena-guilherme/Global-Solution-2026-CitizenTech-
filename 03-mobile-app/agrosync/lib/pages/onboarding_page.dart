import 'package:flutter/material.dart';

import 'package:agrosync/repositories/local_storage.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/widgets/foto_slot.dart';

class _Passo {
  final String emoji;
  final String titulo;
  final String texto;
  final SlotImagem foto;
  const _Passo(this.emoji, this.titulo, this.texto, this.foto);
}

/// Abre o guia inicial (3 passos) como um diálogo sobre o app.
Future<void> mostrarOnboarding(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => const _OnboardingDialog(),
  );
  await LocalStorage.instance.marcarOnboardingVisto();
}

class _OnboardingDialog extends StatefulWidget {
  const _OnboardingDialog();

  @override
  State<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<_OnboardingDialog> {
  int _indice = 0;

  static final List<_Passo> _passos = [
    _Passo(
      '🌱',
      'Bem-vindo ao Guia Inicial',
      'O AgroSync reúne dados climáticos, painel de irrigação e comunidade em um só lugar para apoiar sua produção.',
      Imagens.guiaBoasVindas,
    ),
    _Passo(
      '🔔',
      'Central de Alertas & Clima',
      'Monitore o solo e receba avisos climáticos em tempo real, mesmo com conexão instável no campo.',
      Imagens.guiaAlertas,
    ),
    _Passo(
      '💬',
      'Comunidade de Produtores',
      'Troque experiências, envie fotos de sua lavoura e aprenda com quem cultiva perto de você.',
      Imagens.guiaComunidade,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final passo = _passos[_indice];
    final ultimo = _indice == _passos.length - 1;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FotoSlot(
              slot: passo.foto,
              altura: 120,
              raio: 16,
              escurecer: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.25)],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: escuro ? AppTheme.verdeProfundo : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(passo.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 14),
            Text(passo.titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(passo.texto,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.5, height: 1.4, color: Paleta.of(context).mudo)),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _passos.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _indice ? 14 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _indice
                          ? AppTheme.verde
                          : Paleta.of(context).borda,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Paleta.of(context).suave,
                      foregroundColor: Paleta.of(context).mudo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Pular Guia',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (ultimo) {
                        Navigator.pop(context);
                      } else {
                        setState(() => _indice++);
                      }
                    },
                    child: Text(ultimo ? 'Concluir ✓' : 'Próximo ➔',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
