import 'package:flutter/material.dart';
import 'package:agrosync/models/alerta_model.dart';
import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/helpers.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/widgets/custom_card.dart';
import 'package:agrosync/widgets/foto_slot.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  List<Alerta> _alertas = [];
  bool _carregando = true;
  String? _erro;
  int _requisicaoId = 0;

  Severidade? _severidade;
  TipoAlerta? _tipo;

  static const _faq = [
    (
      'Como o app me ajuda no dia a dia?',
      'Ele reúne clima, umidade do solo e relatos de outros produtores para você saber quando irrigar, colher ou proteger a plantação. Os últimos dados ficam salvos e podem ser consultados sem internet.'
    ),
    (
      'O sensor de umidade é obrigatório?',
      'Não. Você pode registrar a umidade manualmente no Painel. O sensor (Arduino) é um complemento que envia as leituras automaticamente.'
    ),
    (
      'O que significam os níveis de alerta?',
      'Crítico: aja hoje. Moderado: planeje uma ação nas próximas horas. Normal: tudo certo, apenas informativo.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final idAtual = ++_requisicaoId;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await ApiRepository.instance.listarAlertas(
        tipo: _tipo,
        severidade: _severidade,
      );
      if (!mounted || idAtual != _requisicaoId) return;
      setState(() {
        _alertas = lista;
        _erro = null;
      });
    } on ApiException catch (e) {
      if (!mounted || idAtual != _requisicaoId) return;
      setState(() {
        _erro = e.mensagem;
      });
    } catch (_) {
      if (!mounted || idAtual != _requisicaoId) return;
      setState(() {
        _erro = 'Não foi possível carregar os alertas no momento.';
      });
    } finally {
      if (mounted && idAtual == _requisicaoId) {
        setState(() => _carregando = false);
      }
    }
  }

  void _limparFiltros() {
    setState(() {
      _severidade = null;
      _tipo = null;
    });
    _carregar();
  }

  Future<void> _marcarLido(Alerta a) async {
    if (a.lido) return;
    setState(() => a.lido = true);
    try {
      await ApiRepository.instance.marcarAlertaLido(a.id);
    } on ApiException {
      if (mounted) setState(() => a.lido = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Paleta.of(context);
    final novos = _alertas.where((a) => !a.lido).length;
    final temFiltroAtivo = _severidade != null || _tipo != null;

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Central de Alertas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          FotoSlot(
            slot: Imagens.alertasBanner,
            altura: 120,
            escurecer: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.verdeProfundo.withValues(alpha: 0.88),
                AppTheme.verdeProfundo.withValues(alpha: 0.25),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MONITORAMENTO DA LAVOURA',
                      style: TextStyle(
                          color: AppTheme.menta,
                          fontSize: 10.5,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Saiba antes o que fazer\npara proteger a safra',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.25)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _cartaoSobre(p),
          _filtros(),
          const SizedBox(height: 14),
          TituloSecao(
            'Alertas e notificações',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_carregando)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (novos > 0) Selo('$novos novos', cor: AppTheme.verde),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_carregando && _alertas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_erro != null && _alertas.isEmpty)
            SizedBox(
              height: 260,
              child: EstadoVazio(
                emoji: '📡',
                titulo: 'Não foi possível carregar',
                mensagem: _erro,
                onAcao: _carregar,
              ),
            )
          else if (_alertas.isEmpty)
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EstadoVazio(
                      emoji: '✅',
                      ilustracao: Imagens.ilustracaoSemAlertas,
                      titulo: temFiltroAtivo
                          ? 'Nenhum alerta para esse filtro'
                          : 'Nenhum alerta por aqui',
                      mensagem: temFiltroAtivo
                          ? 'Tente combinar outra severidade ou tipo de alerta.'
                          : 'Quando houver risco para a sua lavoura, ele aparece nesta lista.',
                    ),
                    if (temFiltroAtivo) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _limparFiltros,
                        child: const Text('Limpar filtros'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ..._alertas.map(_cartaoAlerta),
        ],
      ),
    );
  }

  Widget _cartaoSobre(Paleta p) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️  Sobre o AgroSync',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Solução CitizenTech para pequenos produtores de hortaliças e frutas. '
            'Reduz a perda de safra por falta de informação, unindo previsão do tempo, '
            'sensores de umidade e uma comunidade colaborativa em um só lugar.',
            style: TextStyle(color: p.mudo, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 4),
          for (final (pergunta, resposta) in _faq)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(pergunta,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                children: [Text(resposta, style: TextStyle(color: p.mudo, height: 1.4))],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filtros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: _severidade == null,
              onSelected: (_) {
                setState(() => _severidade = null);
                _carregar();
              },
            ),
            for (final s in Severidade.values)
              ChoiceChip(
                label: Text(s.rotulo),
                selected: _severidade == s,
                onSelected: (selecionado) {
                  setState(() => _severidade = selecionado ? s : null);
                  _carregar();
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Todos os tipos'),
              selected: _tipo == null,
              onSelected: (_) {
                setState(() => _tipo = null);
                _carregar();
              },
            ),
            for (final t in TipoAlerta.values)
              ChoiceChip(
                label: Text('${t.emoji} ${t.rotulo}'),
                selected: _tipo == t,
                onSelected: (selecionado) {
                  setState(() => _tipo = selecionado ? t : null);
                  _carregar();
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _cartaoAlerta(Alerta a) {
    final cor = AppTheme.corSeveridade(a.severidade);
    final p = Paleta.of(context);
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (aberto) {
            if (aberto) _marcarLido(a);
          },
          leading: Text(a.envolveChuva ? '🌧️' : a.tipo.emoji,
              style: const TextStyle(fontSize: 28)),
          title: Text(a.titulo ?? '',
              style: TextStyle(
                  fontWeight: a.lido ? FontWeight.w600 : FontWeight.w800)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.mensagem, style: TextStyle(color: p.mudo, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Selo(a.severidade.rotulo, cor: cor),
                    if (a.areaNome.isNotEmpty) Selo(a.areaNome, cor: const Color(0xFF546E7A)),
                    if (a.envolveChuva) const Selo('Chuva', cor: AppTheme.azul),
                    if (!a.lido) const Selo('Novo', cor: AppTheme.verde),
                    Text(Fmt.relativo(a.dataHora),
                        style: TextStyle(fontSize: 11.5, color: p.mudo)),
                  ],
                ),
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('O que fazer', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(a.recomendacao ?? 'Sem recomendação específica.',
                style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}