import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/helpers.dart';

/// Permite anexar uma foto: tirar na hora (câmera) ou escolher da galeria.
class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key, required this.onChanged});

  /// Chamado com o arquivo escolhido (ou null quando a foto é removida).
  final ValueChanged<File?> onChanged;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _arquivo;

  Future<void> _escolher(ImageSource origem) async {
    try {
      final foto = await _picker.pickImage(
        source: origem,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80, // reduz o tamanho para o envio funcionar em rede lenta
      );
      if (foto == null) return; // usuário cancelou
      setState(() => _arquivo = File(foto.path));
      widget.onChanged(_arquivo);
    } catch (_) {
      if (!mounted) return;
      final nome = origem == ImageSource.camera ? 'a câmera' : 'a galeria';
      mostrarMensagem(
        context,
        'Não foi possível acessar $nome. Verifique as permissões do app.',
        erro: true,
      );
    }
  }

  void _remover() {
    setState(() => _arquivo = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final p = Paleta.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_arquivo != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _arquivo!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: 'Remover foto',
                  onPressed: _remover,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          )
        else
          Container(
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: p.borda),
              color: p.campo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 36, color: p.mudo),
                const SizedBox(height: 6),
                Text('Nenhuma foto anexada',
                    style: TextStyle(color: p.mudo)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _escolher(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Câmera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _escolher(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
