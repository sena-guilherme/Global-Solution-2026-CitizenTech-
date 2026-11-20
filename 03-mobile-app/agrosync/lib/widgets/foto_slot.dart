import 'package:flutter/material.dart';

import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/imagens.dart';

/// Mostra um [SlotImagem]:
///   1º o arquivo que você colocou em assets/imagens/,
///   2º a foto padrão da internet (se houver),
///   3º um fundo verde com emoji.
class FotoSlot extends StatelessWidget {
  const FotoSlot({
    super.key,
    required this.slot,
    this.altura = 160,
    this.raio = 16,
    this.escurecer,
    this.child,
  });

  final SlotImagem slot;
  final double altura;
  final double raio;

  /// Gradiente por cima da foto (melhora a leitura do texto).
  final Gradient? escurecer;

  /// Conteúdo desenhado sobre a foto.
  final Widget? child;

  Widget _fundo() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.verdeEscuro, AppTheme.verdeProfundo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(slot.emoji, style: const TextStyle(fontSize: 40)),
      );

  Widget _internet() {
    final url = slot.urlReserva;
    if (url == null) return _fundo();
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, filho, progresso) =>
          progresso == null ? filho : _fundo(),
      errorBuilder: (_, __, ___) => _fundo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: SizedBox(
        height: altura,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              slot.caminho,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _internet(), // arquivo ainda não existe
            ),
            if (escurecer != null)
              DecoratedBox(decoration: BoxDecoration(gradient: escurecer)),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

/// Ilustração (PNG transparente) das telas vazias. Sem arquivo, mostra o emoji.
class IlustracaoSlot extends StatelessWidget {
  const IlustracaoSlot({super.key, required this.slot, this.tamanho = 130});

  final SlotImagem slot;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Image.asset(
        slot.caminho,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Text(slot.emoji, style: TextStyle(fontSize: tamanho * 0.45)),
        ),
      ),
    );
  }
}
