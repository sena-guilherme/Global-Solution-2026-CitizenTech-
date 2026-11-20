import 'package:flutter/material.dart';

import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/widgets/foto_slot.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 14),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = Paleta.of(context);
    return Padding(
      padding: margin,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.borda),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Faixa de aviso (offline, modo demonstração).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.texto,
    this.icone = Icons.info_outline,
    this.cor,
  });

  final String texto;
  final IconData icone;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final c = cor ?? AppTheme.verde;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: c.withValues(alpha: 0.14),
      child: Row(
        children: [
          Icon(icone, size: 18, color: c),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

/// Estado vazio / erro com ação opcional.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.emoji,
    required this.titulo,
    this.mensagem,
    this.rotuloAcao,
    this.onAcao,
    this.ilustracao,
  });

  /// Ilustração opcional (PNG) no lugar do emoji. Veja Imagens.ilustracao*.
  final SlotImagem? ilustracao;
  final String emoji;
  final String titulo;
  final String? mensagem;
  final String? rotuloAcao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final p = Paleta.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ilustracao != null)
              IlustracaoSlot(slot: ilustracao!)
            else
              Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            if (mensagem != null) ...[
              const SizedBox(height: 8),
              Text(mensagem!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.mudo)),
            ],
            if (onAcao != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: onAcao, child: Text(rotuloAcao ?? 'Tentar novamente')),
            ],
          ],
        ),
      ),
    );
  }
}

/// Etiqueta colorida pequena (severidade, categoria, área...).
class Selo extends StatelessWidget {
  const Selo(this.texto, {super.key, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: cor)),
    );
  }
}

/// Título de seção em caixa alta pequena (ex.: HISTÓRICO DE LEITURAS).
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key, this.trailing});

  final String texto;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(texto.toUpperCase(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Paleta.of(context).texto,
              )),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
