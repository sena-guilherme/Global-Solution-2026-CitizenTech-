import 'package:flutter/material.dart';
import 'package:agrosync/models/area_model.dart';
import 'package:agrosync/models/cultura_model.dart';
import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/repositories/clima_repository.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/helpers.dart';
import 'package:agrosync/widgets/custom_button.dart';

class CadastroAreaPage extends StatefulWidget {
  const CadastroAreaPage({super.key, this.area});

  final Area? area;

  @override
  State<CadastroAreaPage> createState() => _CadastroAreaPageState();
}

class _CadastroAreaPageState extends State<CadastroAreaPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _tamanho;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late final TextEditingController _cultura;
  late TipoCultura _tipo;
  late Estagio _estagio;
  late DateTime _dataPlantio;
  bool _salvando = false;
  bool _buscandoGps = false;

  bool get _edicao => widget.area != null;

  @override
  void initState() {
    super.initState();
    final a = widget.area;
    final c = a?.cultura;
    _nome = TextEditingController(text: a?.nome ?? '');
    _tamanho = TextEditingController(text: a == null ? '' : Fmt.numero(a.tamanhoHa, 2));
    _latitude = TextEditingController(text: a == null ? '' : a.latitude.toStringAsFixed(6));
    _longitude = TextEditingController(text: a == null ? '' : a.longitude.toStringAsFixed(6));
    _cultura = TextEditingController(text: c?.nome ?? '');
    _tipo = c?.tipo ?? TipoCultura.hortalica;
    _estagio = c?.estagio ?? Estagio.germinacao;
    _dataPlantio = c?.dataPlantio ?? DateTime.now();
  }

  @override
  void dispose() {
    _nome.dispose();
    _tamanho.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _cultura.dispose();
    super.dispose();
  }

  Future<void> _usarMinhaLocalizacao() async {
    setState(() => _buscandoGps = true);
    try {
      final pos = await ClimaRepository().posicaoAtual();
      _latitude.text = pos.lat.toStringAsFixed(6);
      _longitude.text = pos.lon.toStringAsFixed(6);
      if (mounted) mostrarMensagem(context, 'Localização preenchida pelo GPS.');
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível obter a localização.', erro: true);
    } finally {
      if (mounted) setState(() => _buscandoGps = false);
    }
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataPlantio,
      firstDate: DateTime(hoje.year - 2),
      lastDate: DateTime(hoje.year + 1),
      helpText: 'Data do plantio',
    );
    if (escolhida != null) setState(() => _dataPlantio = escolhida);
  }

  double _numero(String v) => double.parse(v.replaceAll(',', '.'));

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final area = Area(
        id: widget.area?.id,
        nome: _nome.text.trim(),
        tamanhoHa: _numero(_tamanho.text),
        latitude: _numero(_latitude.text),
        longitude: _numero(_longitude.text),
        cultura: Cultura(
          id: widget.area?.cultura?.id,
          tipo: _tipo,
          nome: _cultura.text.trim(),
          dataPlantio: _dataPlantio,
          estagio: _estagio,
        ),
      );
      await ApiRepository.instance.salvarArea(area);
      if (!mounted) return;
      mostrarMensagem(
          context, _edicao ? 'Área atualizada!' : 'Área cadastrada com sucesso!');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarMensagem(context, e.mensagem, erro: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _obrigatorio(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? _faixa(String? v, double min, double max, String nome) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    if (n == null) return 'Informe $nome';
    if (n < min || n > max) return '$nome entre ${min.toInt()} e ${max.toInt()}';
    return null;
  }

  Widget _campo(String rotulo, Widget campo) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(rotulo,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
            ),
            campo,
          ],
        ),
      );

  Widget _secao(String titulo) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 12),
        child: Text(titulo.toUpperCase(),
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppTheme.verde)),
      );

  @override
  Widget build(BuildContext context) {
    final p = Paleta.of(context);
    const decimal = TextInputType.numberWithOptions(decimal: true, signed: true);
    return Scaffold(
      appBar: AppBar(title: Text(_edicao ? 'Editar área e cultura' : 'Cadastro de área e cultura')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informe a área de cultivo, a localização e o que está plantado para receber previsões e alertas.',
                style: TextStyle(color: p.mudo, height: 1.4),
              ),
              const SizedBox(height: 18),
              _secao('Área'),
              _campo(
                'Nome da área',
                TextFormField(
                  controller: _nome,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Ex.: Horta Principal'),
                  validator: (v) => _obrigatorio(v, 'Informe o nome da área'),
                ),
              ),
              _campo(
                'Tamanho (hectares)',
                TextFormField(
                  controller: _tamanho,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Ex.: 1,5', suffixText: 'ha'),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    return (n == null || n <= 0) ? 'Informe um tamanho maior que zero' : null;
                  },
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _campo(
                      'Latitude',
                      TextFormField(
                        controller: _latitude,
                        keyboardType: decimal,
                        decoration: const InputDecoration(hintText: '-23,5505'),
                        validator: (v) => _faixa(v, -90, 90, 'Latitude'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campo(
                      'Longitude',
                      TextFormField(
                        controller: _longitude,
                        keyboardType: decimal,
                        decoration: const InputDecoration(hintText: '-46,6333'),
                        validator: (v) => _faixa(v, -180, 180, 'Longitude'),
                      ),
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _buscandoGps ? null : _usarMinhaLocalizacao,
                icon: _buscandoGps
                    ? const SizedBox(
                        height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: const Text('Usar minha localização (GPS)'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
              const SizedBox(height: 22),
              _secao('Cultura plantada'),
              _campo(
                'Tipo',
                DropdownButtonFormField<TipoCultura>(
                  initialValue: _tipo,
                  items: [
                    for (final t in TipoCultura.values)
                      DropdownMenuItem(value: t, child: Text(t.rotulo)),
                  ],
                  onChanged: (v) => setState(() => _tipo = v!),
                ),
              ),
              _campo(
                'Nome da cultura',
                TextFormField(
                  controller: _cultura,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Ex.: Alface Crespa, Morango'),
                  validator: (v) => _obrigatorio(v, 'Informe a cultura'),
                ),
              ),
              _campo(
                'Data do plantio',
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _escolherData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_month_outlined)),
                    child: Text(Fmt.data(_dataPlantio)),
                  ),
                ),
              ),
              _campo(
                'Estágio',
                DropdownButtonFormField<Estagio>(
                  initialValue: _estagio,
                  items: [
                    for (final e in Estagio.values)
                      DropdownMenuItem(value: e, child: Text(e.rotulo)),
                  ],
                  onChanged: (v) => setState(() => _estagio = v!),
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: _edicao ? 'Salvar alterações' : 'Salvar área e cultura',
                icon: Icons.save,
                carregando: _salvando,
                onPressed: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
