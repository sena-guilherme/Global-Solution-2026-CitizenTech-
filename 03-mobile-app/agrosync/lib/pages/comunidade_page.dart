import 'dart:io';

import 'package:flutter/material.dart';

import 'package:agrosync/models/publicacao_model.dart';
import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/helpers.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/widgets/custom_button.dart';
import 'package:agrosync/widgets/custom_card.dart';
import 'package:agrosync/widgets/foto_slot.dart';
import 'package:agrosync/pages/novo_relato_page.dart';

class ComunidadePage extends StatefulWidget {
  const ComunidadePage({super.key});

  @override
  State<ComunidadePage> createState() => _ComunidadePageState();
}

class _ComunidadePageState extends State<ComunidadePage> {
  final _busca = TextEditingController();
  final List<Publicacao> _itens = [];
  bool _minhaRegiao = false;
  int _pagina = 0;
  bool _ultima = false;
  bool _carregando = true;
  bool _carregandoMais = false;
  String? _erro;
  int _requisicaoId = 0;

  String get _regiaoDoUsuario => ApiRepository.instance.usuario?.regiao ?? '';

  bool get _temFiltroAtivo =>
      _busca.text.trim().isNotEmpty || (_minhaRegiao && _regiaoDoUsuario.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  String? get _filtroRegiao =>
      _minhaRegiao && _regiaoDoUsuario.isNotEmpty ? _regiaoDoUsuario : null;

  void _limparFiltros() {
    _busca.clear();
    setState(() {
      _minhaRegiao = false;
    });
    _carregar();
  }

  Future<void> _carregar() async {
    final idAtual = ++_requisicaoId;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final p = await ApiRepository.instance.listarPublicacoes(
        regiao: _filtroRegiao,
        busca: _busca.text.trim(),
      );
      if (!mounted || idAtual != _requisicaoId) return;
      setState(() {
        _itens
          ..clear()
          ..addAll(p.itens);
        _pagina = 0;
        _ultima = p.ultima;
        _erro = null;
      });
    } on ApiException catch (e) {
      if (!mounted || idAtual != _requisicaoId) return;
      setState(() => _erro = e.mensagem);
    } catch (_) {
      if (!mounted || idAtual != _requisicaoId) return;
      setState(() => _erro = 'Não foi possível carregar os relatos da comunidade.');
    } finally {
      if (mounted && idAtual == _requisicaoId) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _carregarMais() async {
    if (_carregandoMais || _ultima) return;
    final idAtual = _requisicaoId;
    setState(() => _carregandoMais = true);
    try {
      final p = await ApiRepository.instance.listarPublicacoes(
        regiao: _filtroRegiao,
        busca: _busca.text.trim(),
        pagina: _pagina + 1,
      );
      if (!mounted || idAtual != _requisicaoId) return;
      setState(() {
        _itens.addAll(p.itens);
        _pagina++;
        _ultima = p.ultima;
      });
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    } catch (_) {
      if (mounted) {
        mostrarMensagem(context, 'Não foi possível carregar mais relatos.', erro: true);
      }
    } finally {
      if (mounted && idAtual == _requisicaoId) {
        setState(() => _carregandoMais = false);
      }
    }
  }

  Future<void> _novoRelato() async {
    final publicou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NovoRelatoPage()),
    );
    if (publicou == true) _carregar();
  }

  Future<void> _confirmar(Publicacao p) async {
    final novoEstado = !p.confirmado;
    final contagemInicial = p.confirmacoes;
    final contagemFinal = contagemInicial + (novoEstado ? 1 : -1);
    setState(() {
      p.confirmado = novoEstado;
      p.confirmacoes = contagemFinal;
    });
    try {
      final atual = await ApiRepository.instance.confirmar(p.id, confirmar: novoEstado);
      if (!mounted) return;
      setState(() {
        p.confirmacoes = identical(atual, p) ? contagemFinal : atual.confirmacoes;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        p.confirmado = !novoEstado;
        p.confirmacoes = contagemInicial;
      });
      mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  Future<void> _excluir(Publicacao p) async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir relato?',
      mensagem: 'Essa ação não pode ser desfeita.',
      acao: 'Excluir',
    );
    if (!ok) return;
    try {
      await ApiRepository.instance.excluirPublicacao(p.id);
      if (!mounted) return;
      setState(() => _itens.removeWhere((x) => x.id == p.id));
      mostrarMensagem(context, 'Relato excluído.');
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Paleta.of(context);
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Comunidade Rural',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Troca de relatos entre produtores',
                        style: TextStyle(fontSize: 12.5, color: p.mudo)),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _novoRelato,
                child: const Text('+ Relato', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FotoSlot(
            slot: Imagens.comunidadeBanner,
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
                child: Text('Aprenda com quem\nplanta perto de você',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.25)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _busca,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _carregar(),
            decoration: InputDecoration(
              hintText: 'Filtrar por produtor, cultura ou região...',
              fillColor: p.card,
              suffixIcon: _busca.text.isEmpty
                  ? IconButton(icon: const Icon(Icons.search), onPressed: _carregar)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _busca.clear();
                        setState(() {});
                        _carregar();
                      },
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Todas as regiões'),
                selected: !_minhaRegiao,
                onSelected: (_) {
                  setState(() => _minhaRegiao = false);
                  _carregar();
                },
              ),
              if (_regiaoDoUsuario.isNotEmpty)
                ChoiceChip(
                  label: Text('📍 $_regiaoDoUsuario'),
                  selected: _minhaRegiao,
                  onSelected: (selecionado) {
                    setState(() => _minhaRegiao = selecionado);
                    _carregar();
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_carregando && _itens.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_erro != null && _itens.isEmpty)
            SizedBox(
              height: 260,
              child: EstadoVazio(
                emoji: '📡',
                titulo: 'Não foi possível carregar o feed',
                mensagem: _erro,
                onAcao: _carregar,
              ),
            )
          else if (_itens.isEmpty)
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EstadoVazio(
                      emoji: '💬',
                      ilustracao: Imagens.ilustracaoSemRelatos,
                      titulo: _temFiltroAtivo
                          ? 'Nenhum relato encontrado'
                          : 'Nenhum relato por aqui ainda',
                      mensagem: _temFiltroAtivo
                          ? 'Tente outro termo de busca ou limpe os filtros.'
                          : 'Seja o primeiro a compartilhar o que está acontecendo na sua lavoura.',
                    ),
                    if (_temFiltroAtivo) ...[
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
          else ...[
            if (_carregando)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            for (final pub in _itens) _cartao(pub),
            if (!_ultima)
              CustomButton(
                label: 'Carregar mais',
                outlined: true,
                carregando: _carregandoMais,
                onPressed: _carregarMais,
              ),
          ],
        ],
      ),
    );
  }

  Widget _cartao(Publicacao pub) {
    final p = Paleta.of(context);
    final eu = ApiRepository.instance.usuario;
    final podeExcluir = eu != null && (eu.id == pub.autorId || eu.isAdmin);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pub.autor,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${pub.regiao} • ${Fmt.relativo(pub.dataHora)}',
                        style: TextStyle(fontSize: 11.5, color: p.mudo)),
                  ],
                ),
              ),
              if (pub.cultura.isNotEmpty) Selo(pub.cultura, cor: AppTheme.verde),
              if (podeExcluir)
                SizedBox(
                  width: 34,
                  height: 26,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Excluir',
                    iconSize: 18,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _excluir(pub),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(pub.texto, style: const TextStyle(fontSize: 13.5, height: 1.4)),
          if (pub.imagemUrl != null || pub.imagemLocal != null || pub.imagemSlot != null) ...[
            const SizedBox(height: 12),
            _foto(pub),
          ],
          const SizedBox(height: 12),
          Divider(color: p.borda, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text('Apoio da comunidade',
                    style: TextStyle(fontSize: 11.5, color: p.mudo)),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _confirmar(pub),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: pub.confirmado
                        ? AppTheme.verde
                        : AppTheme.verde.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('🔥 Útil (${pub.confirmacoes})',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: pub.confirmado ? Colors.white : AppTheme.verde)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _foto(Publicacao pub) {
    final p = Paleta.of(context);
    Widget erro() => Container(
          height: 150,
          alignment: Alignment.center,
          color: p.suave,
          child: const Text('📷  Foto indisponível', style: TextStyle(fontSize: 14)),
        );
    if (pub.imagemSlot != null) {
      return FotoSlot(slot: pub.imagemSlot!, altura: 200, raio: 12);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: pub.imagemLocal != null
          ? Image.file(File(pub.imagemLocal!),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => erro())
          : Image.network(
              ApiRepository.instance.urlImagem(pub.imagemUrl!),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progresso) => progresso == null
                  ? child
                  : Container(
                      height: 200,
                      color: p.suave,
                      child: const Center(child: CircularProgressIndicator())),
              errorBuilder: (_, __, ___) => erro(),
            ),
    );
  }
}