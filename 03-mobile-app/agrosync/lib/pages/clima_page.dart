import 'package:flutter/material.dart';

import 'package:agrosync/repositories/api_exception.dart';
import 'package:agrosync/repositories/clima_repository.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/helpers.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/widgets/custom_card.dart';
import 'package:agrosync/widgets/foto_slot.dart';

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});

  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  final _repo = ClimaRepository();
  final _busca = TextEditingController();

  ClimaModel? _clima;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicial();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  /// Abre já com o último clima salvo (funciona offline) e tenta atualizar.
  Future<void> _inicial() async {
    final salvo = _repo.ultimoSalvo();
    if (salvo != null) {
      setState(() => _clima = salvo);
      await _executar(() => _repo.porCoordenadas(
          salvo.latitude, salvo.longitude, salvo.local,
          gps: salvo.usouGps));
    } else {
      await _executar(_repo.porGps);
    }
  }

  Future<void> _executar(Future<ClimaModel> Function() busca) async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultado = await busca();
      if (!mounted) return;
      setState(() => _clima = resultado);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível obter o clima agora.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _buscarMunicipio() {
    final nome = _busca.text.trim();
    if (nome.isEmpty) return;
    FocusScope.of(context).unfocus();
    _executar(() => _repo.porMunicipio(nome));
  }

  /// Alertas simples derivados da previsão dos próximos dias.
  List<String> _alertasClimaticos(ClimaModel c) {
    final lista = <String>[];
    for (final d in c.dias) {
      final dia = Fmt.diaSemana(d.data);
      if (d.chuvaMm >= 30) {
        lista.add('$dia: chuva forte prevista (${Fmt.numero(d.chuvaMm, 0)} mm). Adie a adubação e limpe o escoamento.');
      }
      if (d.minima <= 5) {
        lista.add('$dia: risco de geada (mínima de ${Fmt.numero(d.minima, 0)}°C). Proteja as hortaliças.');
      }
      if (d.maxima >= 35) {
        lista.add('$dia: calor intenso (${Fmt.numero(d.maxima, 0)}°C). Reforce a irrigação cedo ou ao fim do dia.');
      }
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final c = _clima;
    final p = Paleta.of(context);
    return RefreshIndicator(
      onRefresh: () => c == null
          ? _executar(_repo.porGps)
          : _executar(() => _repo.porCoordenadas(c.latitude, c.longitude, c.local, gps: c.usouGps)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Clima & Região',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              // Toque para usar o GPS.
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _carregando ? null : () => _executar(_repo.porGps),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: p.borda),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text('📍 ${c?.local ?? 'Usar GPS'}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FotoSlot(
            slot: Imagens.climaBanner,
            altura: 100,
            escurecer: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.verdeProfundo.withValues(alpha: 0.85),
                AppTheme.verdeProfundo.withValues(alpha: 0.2),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Planeje a semana\nda sua lavoura',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.25)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _busca,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _buscarMunicipio(),
                  decoration: InputDecoration(
                    hintText: 'Buscar município...',
                    fillColor: p.card,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.navy,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  onPressed: _carregando ? null : _buscarMunicipio,
                  child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          if (_carregando)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomCard(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.errorContainer,
                child: Text(_erro!),
              ),
            ),
          const SizedBox(height: 14),
          if (c == null && !_carregando && _erro != null)
            const SizedBox(
              height: 240,
              child: EstadoVazio(
                emoji: '📍',
                titulo: 'Escolha um local',
                mensagem: 'Busque pelo município ou toque em "Usar GPS".',
              ),
            ),
          if (c != null) ..._conteudo(context, c),
        ],
      ),
    );
  }

  List<Widget> _conteudo(BuildContext context, ClimaModel c) {
    final alertas = _alertasClimaticos(c);
    final p = Paleta.of(context);
    final hoje = c.hoje;
    return [
      if (c.deCache)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InfoBanner(
              texto: 'Modo offline: dados de ${Fmt.dataHora(c.atualizadoEm)}.',
              icone: Icons.cloud_off,
              cor: AppTheme.laranja,
            ),
          ),
        ),
      CustomCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.usouGps ? '${c.local} (GPS Ativo)' : c.local,
                          style: TextStyle(fontSize: 12.5, color: p.mudo)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${Fmt.numero(c.temperatura, 0)}°C',
                              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(ClimaModel.descricao(c.codigo),
                                  style: TextStyle(fontSize: 13, color: p.mudo)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(ClimaModel.emoji(c.codigo), style: const TextStyle(fontSize: 46)),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: p.borda, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _medida('Chuva', '${Fmt.numero(hoje.chuvaMm, 0)}mm (${hoje.probChuva}%)')),
                const SizedBox(width: 10),
                Expanded(child: _medida('Umidade Ar', '${Fmt.numero(c.umidadeAr, 0)}%')),
                const SizedBox(width: 10),
                Expanded(child: _medida('Vento', '${Fmt.numero(c.ventoKmh, 0)} km/h')),
              ],
            ),
          ],
        ),
      ),
      if (alertas.isNotEmpty) ...[
        const TituloSecao('Atenção para a sua lavoura'),
        const SizedBox(height: 8),
        for (final a in alertas)
          CustomCard(
            color: AppTheme.laranja.withValues(alpha: 0.14),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(child: Text(a, style: const TextStyle(height: 1.35))),
              ],
            ),
          ),
      ],
      CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TituloSecao('Previsão para ${c.dias.length} dias'),
            const SizedBox(height: 14),
            for (var i = 0; i < c.dias.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(i == 0 ? 'Hoje' : Fmt.diaSemana(c.dias[i].data),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Text(ClimaModel.emoji(c.dias[i].codigo),
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${Fmt.numero(c.dias[i].maxima, 0)}°C / ${Fmt.numero(c.dias[i].minima, 0)}°C',
                          style: TextStyle(fontSize: 12.5, color: p.mudo),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      c.dias[i].chuvaMm < 1 ? 'Sem chuva' : '${Fmt.numero(c.dias[i].chuvaMm, 0)}mm',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: c.dias[i].chuvaMm < 1 ? AppTheme.verde : AppTheme.azul,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _medida(String rotulo, String valor) {
    final p = Paleta.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: p.suave,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(rotulo, style: TextStyle(fontSize: 11.5, color: p.mudo)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(valor,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
