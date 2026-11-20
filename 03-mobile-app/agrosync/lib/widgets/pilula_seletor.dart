import 'package:flutter/material.dart';

import 'package:agrosync/theme/app_theme.dart';

class PilulaSeletor extends StatelessWidget {
  const PilulaSeletor({
    super.key,
    required this.opcoes,
    required this.indice,
    required this.onChanged,
  });

  final List<String> opcoes;
  final int indice;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: escuro ? const Color(0xFF1A263B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < opcoes.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: i == indice ? AppTheme.verde : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  opcoes[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: i == indice
                        ? Colors.white
                        : Paleta.of(context).mudo,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
