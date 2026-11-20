import 'dart:io';

import 'package:flutter/material.dart';

import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/repositories/local_storage.dart';
import 'package:agrosync/utils/helpers.dart';
import 'package:agrosync/widgets/custom_button.dart';
import 'package:agrosync/widgets/image_picker_widget.dart';

class NovoRelatoPage extends StatefulWidget {
  const NovoRelatoPage({super.key});

  @override
  State<NovoRelatoPage> createState() => _NovoRelatoPageState();
}

class _NovoRelatoPageState extends State<NovoRelatoPage> {
  final _form = GlobalKey<FormState>();
  final _texto = TextEditingController();
  final _cultura = TextEditingController();
  late final TextEditingController _regiao = TextEditingController(
      text: ApiRepository.instance.usuario?.regiao.isNotEmpty == true
          ? ApiRepository.instance.usuario!.regiao
          : LocalStorage.instance.ultimaRegiao);
  File? _foto;
  bool _enviando = false;

  @override
  void dispose() {
    _texto.dispose();
    _cultura.dispose();
    _regiao.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ApiRepository.instance.publicar(
        texto: _texto.text.trim(),
        cultura: _cultura.text.trim(),
        regiao: _regiao.text.trim(),
        imagem: _foto,
      );
      await LocalStorage.instance.salvarUltimaRegiao(_regiao.text.trim());
      if (!mounted) return;
      mostrarMensagem(context, 'Relato publicado com sucesso!');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      mostrarMensagem(context, e.mensagem, erro: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo relato')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _texto,
                maxLines: 5,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'O que deu certo ou errado na sua lavoura?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Escreva pelo menos 10 caracteres'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cultura,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 80,
                decoration: const InputDecoration(hintText: 'Cultura (ex.: Alface, Morango)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a cultura' : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _regiao,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration: const InputDecoration(hintText: 'Região (ex.: Sorocaba)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a região' : null,
              ),
              const SizedBox(height: 12),
              const Text('Foto (opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ImagePickerWidget(onChanged: (f) => _foto = f),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Publicar relato',
                icon: Icons.send,
                carregando: _enviando,
                onPressed: _publicar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
