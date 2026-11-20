import 'package:agrosync/models/cultura_model.dart';

/// Um "espaço de imagem" do app.
///
/// Como trocar por uma imagem sua:
///   1. Salve o arquivo na pasta  assets/imagens/  com EXATAMENTE o nome indicado em [arquivo].
///   2. Rode o app de novo (flutter run). Pronto, não precisa mexer em mais nada.
///
/// Ordem de exibição:  seu arquivo  →  foto padrão da internet ([urlReserva])  →  emoji.
class SlotImagem {
  const SlotImagem({required this.arquivo, required this.emoji, this.urlReserva});

  /// Nome do arquivo dentro de assets/imagens/ (a extensão precisa ser igual: .jpg ou .png).
  final String arquivo;

  /// Mostrado quando não há arquivo nem internet.
  final String emoji;

  /// Foto padrão (Pexels, licença gratuita) usada enquanto você não colocar a sua.
  final String? urlReserva;

  String get caminho => 'assets/imagens/$arquivo';
}

/// Todos os lugares do app onde dá para colocar imagem.
/// Em cada um está descrito o TIPO DE IMAGEM que combina melhor.
class Imagens {
  // ------------------------------------------------------------------
  // IDENTIDADE
  // ------------------------------------------------------------------

  /// LOGO do AgroSync.
  /// Onde aparece: splash, cabeçalho verde de todas as telas e tela de login.
  /// Tipo ideal: PNG com fundo TRANSPARENTE, quadrado (512x512), desenho simples de um broto/folha
  ///             em branco ou verde-claro (aparece sobre fundo verde-escuro). Sem texto.
  static const SlotImagem logo = SlotImagem(
    arquivo: 'logo.png',
    emoji: '🌱',
  );

  // ------------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------------

  /// ÍCONE do topo da tela de login (o quadradinho acima de "Bem-vindo(a) ao AgroSync").
  /// Tipo ideal: PNG quadrado (512x512), pode ter fundo transparente. Exibido em 72x72.
  /// Enquanto o arquivo não existir, aparece o ícone padrão (🌾).
  static const SlotImagem loginIcone = SlotImagem(
    arquivo: 'login_icone.png',
    emoji: '🌾',
  );

  /// BANNER do topo da tela de login (formato largo, 3:1 — ex.: 1200x400).
  /// Tipo ideal: foto panorâmica de horta/plantação ao amanhecer, ou agricultor(a) familiar na lavoura.
  ///             Cores verdes e quentes, boa luz, SEM texto na imagem.
  static const SlotImagem loginTopo = SlotImagem(
    arquivo: 'login_topo.jpg',
    emoji: '🌾',
    urlReserva: 'https://images.pexels.com/photos/10817215/pexels-photo-10817215.jpeg?auto=compress&cs=tinysrgb&w=1000',
  );

  // ------------------------------------------------------------------
  // GUIA INICIAL (3 passos) — formato 16:9, ex.: 800x450
  // ------------------------------------------------------------------

  /// Passo 1 — "Bem-vindo ao Guia Inicial".
  /// Tipo ideal: horta ou estufa bem cuidada, vista de frente, fileiras organizadas de hortaliças.
  static const SlotImagem guiaBoasVindas = SlotImagem(
    arquivo: 'guia_1_boas_vindas.jpg',
    emoji: '🌱',
    urlReserva: 'https://images.pexels.com/photos/4199758/pexels-photo-4199758.jpeg?auto=compress&cs=tinysrgb&w=800',
  );

  /// Passo 2 — "Central de Alertas & Clima".
  /// Tipo ideal: céu carregado/chuva sobre a plantação, OU produtor(a) olhando o celular no campo.
  static const SlotImagem guiaAlertas = SlotImagem(
    arquivo: 'guia_2_alertas.jpg',
    emoji: '🔔',
    urlReserva: 'https://images.pexels.com/photos/7658811/pexels-photo-7658811.jpeg?auto=compress&cs=tinysrgb&w=800',
  );

  /// Passo 3 — "Comunidade de Produtores".
  /// Tipo ideal: pessoas colhendo ou conversando juntas, feira/mercado de produtores locais.
  static const SlotImagem guiaComunidade = SlotImagem(
    arquivo: 'guia_3_comunidade.jpg',
    emoji: '💬',
    urlReserva: 'https://images.pexels.com/photos/7658807/pexels-photo-7658807.jpeg?auto=compress&cs=tinysrgb&w=800',
  );

  // ------------------------------------------------------------------
  // BANNERS DAS ABAS (formato largo 3:1 — ex.: 1000x330)
  // O lado ESQUERDO da imagem fica coberto por um degradê escuro com texto branco:
  // prefira fotos em que o assunto principal esteja à direita ou no centro.
  // ------------------------------------------------------------------

  /// Aba ALERTAS.
  /// Tipo ideal: céu dramático (nuvens de tempestade) sobre a lavoura, ou agricultor(a) observando o tempo.
  static const SlotImagem alertasBanner = SlotImagem(
    arquivo: 'alertas_banner.jpg',
    emoji: '🔔',
    urlReserva: 'https://images.pexels.com/photos/7658811/pexels-photo-7658811.jpeg?auto=compress&cs=tinysrgb&w=1000',
  );

  /// Aba CLIMA.
  /// Tipo ideal: céu aberto com sol e nuvens sobre o campo/horizonte, transmitindo "previsão do tempo".
  static const SlotImagem climaBanner = SlotImagem(
    arquivo: 'clima_banner.jpg',
    emoji: '🌤️',
    urlReserva: 'https://images.pexels.com/photos/10817215/pexels-photo-10817215.jpeg?auto=compress&cs=tinysrgb&w=1000',
  );

  /// Aba COMUNIDADE.
  /// Tipo ideal: mãos de produtores segurando a colheita (cestas de verduras/frutas) ou plantio em grupo.
  static const SlotImagem comunidadeBanner = SlotImagem(
    arquivo: 'comunidade_banner.jpg',
    emoji: '💬',
    urlReserva: 'https://images.pexels.com/photos/5793249/pexels-photo-5793249.jpeg?auto=compress&cs=tinysrgb&w=1000',
  );

  // ------------------------------------------------------------------
  // PAINEL — fundo do cartão "CULTURA ATUAL" (formato 16:9, ex.: 800x450)
  // Há um espaço para cada TIPO de cultura do banco: HORTALIÇA e FRUTA.
  // A foto recebe um verde-escuro por cima (~90%), então funciona como TEXTURA:
  // qualquer foto nítida da cultura serve, sem precisar de muito contraste.
  // ------------------------------------------------------------------

  /// Culturas do tipo HORTALIÇA (alface, couve, rúcula...).
  /// Tipo ideal: close-up de folhas em canteiro, com gotas de água se possível.
  static const SlotImagem culturaHortalica = SlotImagem(
    arquivo: 'cultura_hortalica.jpg',
    emoji: '🥬',
    urlReserva: 'https://images.pexels.com/photos/6849628/pexels-photo-6849628.jpeg?auto=compress&cs=tinysrgb&w=800',
  );

  /// Culturas do tipo FRUTA (morango, laranja, maçã...).
  /// Tipo ideal: frutas ainda no pé/planta, maduras, bem coloridas.
  static const SlotImagem culturaFruta = SlotImagem(
    arquivo: 'cultura_fruta.jpg',
    emoji: '🍓',
    urlReserva: 'https://images.pexels.com/photos/5503106/pexels-photo-5503106.jpeg?auto=compress&cs=tinysrgb&w=800',
  );

  static SlotImagem cultura(TipoCultura t) {
    switch (t) {
      case TipoCultura.hortalica:
        return culturaHortalica;
      case TipoCultura.fruta:
        return culturaFruta;
    }
  }

  // ------------------------------------------------------------------
  // RELATOS DE EXEMPLO (aparecem só no MODO DEMONSTRAÇÃO) — formato 4:3, ex.: 800x600
  // ------------------------------------------------------------------

  /// Relato da "Dona Maria": mudas cobertas com sombrite contra o calor.
  /// Tipo ideal: canteiro de hortaliças coberto com tela de sombreamento ou palha.
  static const SlotImagem relatoDemo1 = SlotImagem(
    arquivo: 'relato_demo_1.jpg',
    emoji: '📷',
    urlReserva: 'https://images.pexels.com/photos/6849628/pexels-photo-6849628.jpeg?auto=compress&cs=tinysrgb&w=800',
  );

  /// Relato do "Carlos H.": cuidado com excesso de irrigação.
  /// Tipo ideal: tomates ou morangos na planta, de preferência com irrigação por gotejamento ou terra úmida.
  static const SlotImagem relatoDemo2 = SlotImagem(
    arquivo: 'relato_demo_2.jpg',
    emoji: '📷',
    urlReserva: 'https://images.pexels.com/photos/5503112/pexels-photo-5503112.jpeg?auto=compress&cs=tinysrgb&w=800',
  );

  // ------------------------------------------------------------------
  // ILUSTRAÇÕES DE "TELA VAZIA" — PNG com fundo TRANSPARENTE, quadrado (600x600)
  // Aparecem quando não há conteúdo ainda. Estilo ideal: ilustração simples/flat em tons de verde,
  // sem texto, transmitindo acolhimento (não precisa ser foto).
  // ------------------------------------------------------------------

  /// Painel sem áreas cadastradas. Ideal: broto saindo da terra / mãos plantando uma muda.
  static const SlotImagem ilustracaoSemAreas = SlotImagem(
    arquivo: 'vazio_areas.png',
    emoji: '🌱',
  );

  /// Alertas sem nenhum aviso. Ideal: sol sorrindo sobre a lavoura ou um "check" verde ("tudo tranquilo").
  static const SlotImagem ilustracaoSemAlertas = SlotImagem(
    arquivo: 'vazio_alertas.png',
    emoji: '✅',
  );

  /// Comunidade sem relatos. Ideal: balões de conversa ou duas pessoas conversando.
  static const SlotImagem ilustracaoSemRelatos = SlotImagem(
    arquivo: 'vazio_relatos.png',
    emoji: '💬',
  );
}
