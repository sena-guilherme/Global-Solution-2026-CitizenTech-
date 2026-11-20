import 'package:flutter/material.dart';

import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/repositories/local_storage.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/widgets/app_header.dart';
import 'package:agrosync/widgets/custom_card.dart';
import 'package:agrosync/pages/alertas_page.dart';
import 'package:agrosync/pages/clima_page.dart';
import 'package:agrosync/pages/comunidade_page.dart';
import 'package:agrosync/pages/configuracoes_page.dart';
import 'package:agrosync/pages/onboarding_page.dart';
import 'package:agrosync/pages/painel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indice = 0; // abre no Painel, como no protótipo

  static const _abas = [
    ('🔔', 'Alertas'),
    ('📊', 'Painel'),
    ('🌤️', 'Clima'),
    ('💬', 'Comunidade'),
    ('⚙️', 'Ajustes'),
  ];

  @override
  void initState() {
    super.initState();
    // Primeiro acesso: mostra o guia inicial sobre o app.
    if (!LocalStorage.instance.onboardingVisto) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) mostrarOnboarding(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ApiRepository.instance;
    final p = Paleta.of(context);
    return Scaffold(
      body: Column(
        children: [
          AppHeader(onGuia: () => mostrarOnboarding(context)),
          if (repo.demo)
            const InfoBanner(
              texto: 'Modo demonstração: os dados ficam só neste aparelho.',
              icone: Icons.science_outlined,
            ),
          ValueListenableBuilder<bool>(
            valueListenable: ApiRepository.offline,
            builder: (context, semConexao, _) => semConexao
                ? const InfoBanner(
                    texto: 'Sem conexão: exibindo os últimos dados salvos.',
                    icone: Icons.cloud_off,
                    cor: AppTheme.laranja,
                  )
                : const SizedBox.shrink(),
          ),
          // IndexedStack mantém o estado de cada aba ao trocar.
          Expanded(
            child: IndexedStack(
              index: _indice,
              children: const [
                AlertasPage(),
                PainelPage(),
                ClimaPage(),
                ComunidadePage(),
                ConfiguracoesPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: p.borda))),
        child: NavigationBar(
          selectedIndex: _indice,
          onDestinationSelected: (i) => setState(() => _indice = i),
          destinations: [
            for (var i = 0; i < _abas.length; i++)
              NavigationDestination(
                label: _abas[i].$2,
                icon: Opacity(
                  opacity: 0.45,
                  child: Text(_abas[i].$1, style: const TextStyle(fontSize: 22)),
                ),
                selectedIcon: Text(_abas[i].$1, style: const TextStyle(fontSize: 24)),
              ),
          ],
        ),
      ),
    );
  }
}
