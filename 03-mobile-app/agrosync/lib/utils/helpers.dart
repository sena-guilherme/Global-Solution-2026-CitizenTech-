import 'package:flutter/material.dart';

class Fmt {
  static String _dois(int n) => n.toString().padLeft(2, '0');

  static String dataHora(DateTime d) =>
    '${_dois(d.day)}/${_dois(d.month)}/${d.year} ${_dois(d.hour)}:${_dois(d.minute)}';

  static String dataCurta(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}';

  static String data(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

  static String hora(DateTime d) => '${_dois(d.hour)}:${_dois(d.minute)}';

  static String diaRelativo(DateTime d) {
    final hoje = DateTime.now();
    final a = DateTime(hoje.year, hoje.month, hoje.day);
    final b = DateTime(d.year, d.month, d.day);
    final dif = a.difference(b).inDays;
    final dia = dif == 0 ? 'Hoje' : (dif == 1 ? 'Ontem' : dataCurta(d));
    return '$dia, ${hora(d)}';
  }

  static String relativo(DateTime d) {
    final agora = DateTime.now();
    final diff = agora.difference(d);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    final dias = DateTime(agora.year, agora.month, agora.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (dias == 0) return 'Hoje';
    if (dias == 1) return 'Ontem';
    if (dias < 7) return 'Há $dias dias';
    return dataCurta(d);
  }

  static const _dias = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
    'Sexta-feira', 'Sábado', 'Domingo'
  ];
  static String diaSemana(DateTime d) => _dias[d.weekday - 1];

  static String umidade(double v) =>
      v == v.roundToDouble() ? v.round().toString() : numero(v, 1);

  static String numero(double v, [int casas = 1]) =>
      v.toStringAsFixed(casas).replaceAll('.', ',');
}

void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  final cores = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto,
            style: TextStyle(color: erro ? cores.onError : null)),
        backgroundColor: erro ? cores.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

Future<bool> confirmar(BuildContext context,
    {required String titulo,
    required String mensagem,
    String acao = 'Confirmar'}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true), child: Text(acao)),
      ],
    ),
  );
  return resultado ?? false;
}
