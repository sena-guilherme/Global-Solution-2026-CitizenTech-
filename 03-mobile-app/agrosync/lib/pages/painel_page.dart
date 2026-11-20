import 'package:flutter/material.dart';

import 'package:agrosync/models/area_model.dart';
import 'package:agrosync/models/cultura_model.dart';
import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/repositories/clima_repository.dart';
import 'package:agrosync/repositories/local_storage.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/helpers.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/widgets/custom_button.dart';
import 'package:agrosync/widgets/custom_card.dart';
import 'package:agrosync/widgets/foto_slot.dart';
import 'package:agrosync/widgets/pilula_seletor.dart';
import 'package:agrosync/pages/cadastro_area_page.dart';

enum _AcaoArea { nova, editar, excluir }

/// Painel da safra: área escolhida, cultura, irrigação, umidade, temperatura, relatório e histórico.
class PainelPage extends StatefulWidget {
  const PainelPage({super.key});

  @override
  State<PainelPage> createState() => _PainelPageState();
}

class _PainelPageState extends State<PainelPage> {
  final _clima = ClimaRepository();

  List<Area> _areas = [];
  int? _selecionadoId;
  List<LeituraSolo> _leituras = [];
  RelatorioProdutor? _relatorio;
  double? _temperaturaAr;

  bool _carregando = true;
  String? _erro;
  bool _detalhado = false;
  bool _enviandoLeitura = false;

  final _formLeitura = GlobalKey<FormState>();
  final _umidadeCtrl = TextEditingController();

  Area? get _atual {
    if (_areas.isEmpty) return null;
    return _areas.firstWhere((a) => a.id == _selecionadoId, orElse: () => _areas.first);
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _umidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await ApiRepository.instance.listarAreas();
      if (!mounted) return;
      setState(() {
        _areas = lista;
        _selecionadoId = lista.any((a) => a.id == _selecionadoId)
            ? _selecionadoId
            : (lista.isEmpty ? null : lista.first.id);
      });
      await _carregarDetalhe();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarDetalhe() async {
    final a = _atual;
    if (a == null) return;
    final repo = ApiRepository.instance;
    try {
      final leituras = await repo.listarLeituras(a.id!);
      final relatorio = await repo.relatorio();
      if (!mounted) return;
      setState(() {
        _leituras = leituras;
        _relatorio = relatorio;
      });
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    }
    // temperatura do ar na região da área (Open-Meteo, usa a latitude/longitude cadastradas)
    final t = await _clima.temperaturaAtual(a.latitude, a.longitude);
    if (mounted) setState(() => _temperaturaAr = t);
  }

  /// Recarrega só a área atual (sem refazer a lista inteira).
  Future<void> _recarregarAtual() async {
    final a = _atual;
    if (a == null) return;
    try {
      final nova = await ApiRepository.instance.buscarArea(a.id!);
      if (!mounted) return;
      setState(() {
        final i = _areas.indexWhere((x) => x.id == nova.id);
        if (i >= 0) _areas[i] = nova;
      });
      await _carregarDetalhe();
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  void _trocarArea(int id) {
    setState(() {
      _selecionadoId = id;
      _leituras = [];
      _temperaturaAr = null;
    });
    _carregarDetalhe();
  }

  Future<void> _abrirCadastro([Area? editar]) async {
    // Passagem de parâmetro entre telas: a área a editar (ou null para uma nova).
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CadastroAreaPage(area: editar)),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _excluir(Area a) async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir área?',
      mensagem:
          'A área "${a.nome}", sua cultura, os alertas e todo o histórico de leituras serão apagados.',
      acao: 'Excluir',
    );
    if (!ok || !mounted) return;
    try {
      await ApiRepository.instance.excluirArea(a.id!);
      if (!mounted) return;
      mostrarMensagem(context, 'Área excluída.');
      _selecionadoId = null;
      _carregar();
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  Future<void> _alternarModo(Area a, bool automatica) async {
    await LocalStorage.instance.salvarIrrigacaoAutomatica(a.id!, automatica);
    if (mounted) setState(() {});
  }

  Future<void> _irrigar(Area a) async {
    try {
      await ApiRepository.instance.irrigar(a.id!);
      if (!mounted) return;
      mostrarMensagem(context, 'Irrigação registrada em ${a.nome}!');
      await _carregarDetalhe();
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  Future<void> _registrarLeitura(Area a) async {
    if (!_formLeitura.currentState!.validate()) return;
    setState(() => _enviandoLeitura = true);
    try {
      final valor = double.parse(_umidadeCtrl.text.replaceAll(',', '.'));
      final r = await ApiRepository.instance.registrarLeitura(a.id!, valor);
      _umidadeCtrl.clear();
      if (!mounted) return;
      mostrarMensagem(context,
          'Leitura registrada! Alerta ${r.alerta.severidade.rotulo.toLowerCase()} gerado.');
      await _recarregarAtual();
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    } finally {
      if (mounted) setState(() => _enviandoLeitura = false);
    }
  }

  // ------------------------------------------------------------------ UI
  @override
  Widget build(BuildContext context) {
    if (_carregando && _areas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null && _areas.isEmpty) {
      return EstadoVazio(
        emoji: '📡',
        titulo: 'Não foi possível carregar suas áreas',
        mensagem: _erro,
        onAcao: _carregar,
      );
    }
    final a = _atual;
    if (a == null) {
      return EstadoVazio(
        emoji: '🌱',
        ilustracao: Imagens.ilustracaoSemAreas,
        titulo: 'Nenhuma área cadastrada',
        mensagem:
            'Cadastre sua primeira área e a cultura plantada para acompanhar a umidade do solo e receber alertas.',
        rotuloAcao: 'Cadastrar área',
        onAcao: () => _abrirCadastro(),
      );
    }

    final automatica = LocalStorage.instance.irrigacaoAutomatica(a.id!);
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalho(a),
          const SizedBox(height: 14),
          if (_relatorio != null) ...[
            _indicadores(_relatorio!),
            const SizedBox(height: 14),
          ],
          _cartaoCultura(a),
          const SizedBox(height: 14),
          _cartaoModo(a, automatica),
          if (!automatica) ...[
            const SizedBox(height: 12),
            CustomButton(
              label: 'Registrar irrigação agora',
              icon: Icons.water_drop,
              color: AppTheme.azul,
              onPressed: () => _irrigar(a),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _metricaUmidade(a)),
              const SizedBox(width: 12),
              Expanded(child: _metricaTemperatura()),
            ],
          ),
          const SizedBox(height: 14),
          if (a.ultimaLeitura != null) _cartaoRecomendacao(a),
          _cartaoLeitura(a),
          _cartaoHistorico(),
        ],
      ),
    );
  }

  Widget _cabecalho(Area a) {
    return Row(
      children: [
        const Expanded(
          child: Text('Painel da Safra & Irrigação',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<Object>(
          tooltip: 'Trocar de área',
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (v) {
            if (v is int) {
              _trocarArea(v);
            } else if (v == _AcaoArea.nova) {
              _abrirCadastro();
            } else if (v == _AcaoArea.editar) {
              _abrirCadastro(a);
            } else if (v == _AcaoArea.excluir) {
              _excluir(a);
            }
          },
          itemBuilder: (_) => [
            for (final x in _areas)
              PopupMenuItem<Object>(
                value: x.id!,
                child: Row(
                  children: [
                    Icon(x.id == a.id ? Icons.check_circle : Icons.circle_outlined,
                        size: 18, color: AppTheme.verde),
                    const SizedBox(width: 10),
                    Flexible(child: Text(x.nome)),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem<Object>(value: _AcaoArea.nova, child: Text('➕  Nova área')),
            const PopupMenuItem<Object>(value: _AcaoArea.editar, child: Text('✏️  Editar esta área')),
            const PopupMenuItem<Object>(value: _AcaoArea.excluir, child: Text('🗑️  Excluir esta área')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.verde.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.verde.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text('Área: ${a.nome}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.verde)),
                ),
                const Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.verde),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Indicadores do relatório do produtor (a mesma consulta da procedure sp_relatorio_produtor).
  Widget _indicadores(RelatorioProdutor r) {
    Widget item(String valor, String rotulo, Color cor) => Expanded(
          child: CustomCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Text(valor,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cor)),
                const SizedBox(height: 2),
                Text(rotulo, style: const TextStyle(fontSize: 11.5)),
              ],
            ),
          ),
        );
    return Row(
      children: [
        item('${r.qtdAreas}', 'Áreas', AppTheme.verde),
        const SizedBox(width: 10),
        item('${r.totalAlertas}', 'Alertas', AppTheme.azul),
        const SizedBox(width: 10),
        item('${r.alertasCriticos}', 'Críticos', const Color(0xFFDC2626)),
      ],
    );
  }

  Widget _cartaoCultura(Area a) {
    final c = a.cultura;
    const rotulo = TextStyle(color: Colors.white70, fontSize: 12);
    const valor = TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800);
    return FotoSlot(
      slot: Imagens.cultura(c?.tipo ?? TipoCultura.hortalica),
      altura: 190,
      raio: 20,
      escurecer: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF064E3B).withValues(alpha: 0.93),
          const Color(0xFF022C22).withValues(alpha: 0.80),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CULTURA ATUAL',
                    style: TextStyle(
                        color: AppTheme.menta,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(c?.nome ?? 'Sem cultura cadastrada',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              ],
            ),
            Column(
              children: [
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estágio', style: rotulo),
                          const SizedBox(height: 2),
                          Text(
                              c == null
                                  ? '--'
                                  : '${c.estagio.rotulo} (Dia ${c.diaDoCiclo})',
                              style: valor),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Plantio', style: rotulo),
                          const SizedBox(height: 2),
                          Text(c == null ? '--' : Fmt.data(c.dataPlantio), style: valor),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoModo(Area a, bool automatica) {
    final p = Paleta.of(context);
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Modo de Irrigação',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
              PilulaSeletor(
                opcoes: const ['Automático', 'Manual'],
                indice: automatica ? 0 : 1,
                onChanged: (i) => _alternarModo(a, i == 0),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            automatica
                ? 'Irrigação conforme o sensor e os alertas de umidade.'
                : 'Você decide quando irrigar e registra cada irrigação.',
            style: TextStyle(fontSize: 11.5, color: p.mudo),
          ),
        ],
      ),
    );
  }

  Widget _metricaUmidade(Area a) {
    final p = Paleta.of(context);
    final l = a.ultimaLeitura;
    final cor = l == null ? p.mudo : AppTheme.corClassificacao(l.classificacao);
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Umidade do Solo', style: TextStyle(fontSize: 12.5, color: p.mudo)),
          const SizedBox(height: 6),
          Text(l == null ? '--' : '${Fmt.umidade(l.valorUmidade)}%',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(l == null ? 'Sem leitura ainda' : l.classificacao.rotulo,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: cor)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: l == null ? 0 : (l.valorUmidade / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: p.suave,
              color: AppTheme.azul,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricaTemperatura() {
    final p = Paleta.of(context);
    final t = _temperaturaAr;
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temperatura (ar)', style: TextStyle(fontSize: 12.5, color: p.mudo)),
          const SizedBox(height: 6),
          Text(t == null ? '--' : '${Fmt.numero(t)}°C',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(t == null ? 'Sem dados agora' : 'Na região da área',
              style: TextStyle(fontSize: 11.5, color: p.mudo)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: t == null ? 0 : (t / 50).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: p.suave,
              color: AppTheme.laranja,
            ),
          ),
        ],
      ),
    );
  }

  /// Classificação e ação recomendada pela regra central (< 20, < 35, até 70, > 70).
  Widget _cartaoRecomendacao(Area a) {
    final l = a.ultimaLeitura!;
    final cor = AppTheme.corClassificacao(l.classificacao);
    return CustomCard(
      color: cor.withValues(alpha: 0.10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 4, height: 46, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l.classificacao.rotulo.toUpperCase()} · O que fazer',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: cor)),
                const SizedBox(height: 4),
                Text(a.recomendacao ?? l.classificacao.recomendacao,
                    style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoLeitura(Area a) {
    final p = Paleta.of(context);
    return CustomCard(
      child: Form(
        key: _formLeitura,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TituloSecao('Registrar leitura'),
            const SizedBox(height: 4),
            Text('Use quando não houver sensor instalado. Gera o alerta automaticamente.',
                style: TextStyle(fontSize: 12, color: p.mudo)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _umidadeCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Umidade do solo', suffixText: '%'),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                if (n == null) return 'Informe um número';
                if (n < 0 || n > 100) return 'Informe um valor de 0 a 100';
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Registrar leitura',
              icon: Icons.sensors,
              carregando: _enviandoLeitura,
              onPressed: () => _registrarLeitura(a),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoHistorico() {
    final p = Paleta.of(context);
    final visiveis = _detalhado ? _leituras : _leituras.take(2).toList();
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TituloSecao(
            'Histórico de leituras',
            trailing: GestureDetector(
              onTap: () => setState(() => _detalhado = !_detalhado),
              child: Text(
                _detalhado ? 'Ver resumo ▴' : 'Ver Detalhes ▾',
                style: const TextStyle(
                    color: AppTheme.verde, fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (visiveis.isEmpty)
            Text('Ainda não há leituras para esta área.', style: TextStyle(color: p.mudo))
          else
            for (final l in visiveis)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: p.suave,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${Fmt.diaRelativo(l.dataHora)} (${l.origemRotulo})',
                          style: const TextStyle(fontSize: 12.5)),
                    ),
                    Text(
                      '${Fmt.umidade(l.valorUmidade)}% Umidade (${l.classificacao.rotulo})',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.corClassificacao(l.classificacao)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
