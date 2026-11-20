import 'package:flutter/material.dart';
import 'package:agrosync/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.carregando = false,
    this.outlined = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool carregando;
  final bool outlined;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fundo = color ?? AppTheme.verde;
    final conteudo = carregando
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: outlined ? fundo : Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );

    final acao = carregando ? null : onPressed;
    final forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    final botao = SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: acao,
              style: OutlinedButton.styleFrom(shape: forma),
              child: conteudo,
            )
          : FilledButton(
              onPressed: acao,
              style: FilledButton.styleFrom(shape: forma, backgroundColor: fundo),
              child: conteudo,
            ),
    );

    if (outlined) return botao;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: fundo.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: botao,
    );
  }
}
