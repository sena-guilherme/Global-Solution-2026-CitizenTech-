import 'package:flutter/material.dart';

import 'package:agrosync/main.dart';
import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/helpers.dart';
import 'package:agrosync/widgets/custom_card.dart';
import 'package:agrosync/pages/login_page.dart';
import 'package:agrosync/pages/onboarding_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  static const _tamanhos = [
    ('Pequeno', 0.9),
    ('Médio (Padrão)', 1.0),
    ('Grande', 1.15),
    ('Muito grande', 1.3),
  ];
  static const _fontes = [
    ('Padrão (Sistema)', 'padrao'),
    ('Serifada', 'serifada'),
    ('Monoespaçada', 'mono'),
  ];

  Future<void> _sair() async {
    final ok = await confirmar(context,
        titulo: 'Sair da conta?',
        mensagem: 'Você precisará entrar novamente para acessar seus dados.',
        acao: 'Sair');
    if (!ok) return;
    await ApiRepository.instance.sair();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (rota) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AgroSyncApp.of(context);
    final repo = ApiRepository.instance;
    final p = Paleta.of(context);
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final indiceTamanho = _tamanhos.indexWhere((t) => t.$2 == app.textScale);

    InputDecoration deco() => const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Configurações',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        if (repo.usuario != null)
          CustomCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: p.verdeSuave,
                  child: Text(repo.usuario!.nome.isEmpty ? '?' : repo.usuario!.nome[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.verde)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(repo.usuario!.nome,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(repo.demo ? 'Modo demonstração' : repo.usuario!.email,
                          style: TextStyle(fontSize: 12, color: p.mudo)),
                    ],
                  ),
                ),
                if (repo.usuario!.isAdmin) const Selo('Admin', cor: AppTheme.verde),
              ],
            ),
          ),
        CustomCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aparência do Aplicativo',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('Alternar entre modo Claro e Escuro',
                        style: TextStyle(fontSize: 11.5, color: p.mudo)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  app.setThemeMode(escuro ? ThemeMode.light : ThemeMode.dark);
                  setState(() {});
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: p.suave,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: Text(escuro ? '🌙 Escuro' : '☀️ Claro',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
        ),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Acessibilidade Visual (Fontes)',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tamanho da Fonte',
                            style: TextStyle(fontSize: 11.5, color: p.mudo)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<double>(
                          key: ValueKey('tam-${app.textScale}'),
                          initialValue: indiceTamanho < 0 ? 1.0 : _tamanhos[indiceTamanho].$2,
                          isExpanded: true,
                          decoration: deco(),
                          items: [
                            for (final t in _tamanhos)
                              DropdownMenuItem(
                                value: t.$2,
                                child: Text(t.$1, style: const TextStyle(fontSize: 13)),
                              ),
                          ],
                          onChanged: (v) {
                            app.setTextScale(v!);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Família da Fonte',
                            style: TextStyle(fontSize: 11.5, color: p.mudo)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          key: ValueKey('fonte-${app.fonte}'),
                          initialValue: app.fonte,
                          isExpanded: true,
                          decoration: deco(),
                          items: [
                            for (final f in _fontes)
                              DropdownMenuItem(
                                value: f.$2,
                                child: Text(f.$1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                          ],
                          onChanged: (v) {
                            app.setFonte(v!);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Text('🎓', style: TextStyle(fontSize: 22)),
                title: const Text('Rever guia inicial',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => mostrarOnboarding(context),
              ),
              Divider(height: 1, color: p.borda),
              ListTile(
                leading: const Text('🌍', style: TextStyle(fontSize: 22)),
                title: const Text('Objetivos de Desenvolvimento Sustentável',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text(
                    'ODS 2 (Fome zero e agricultura sustentável), 11 (Cidades e comunidades sustentáveis) e 13 (Ação contra a mudança do clima).'),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: _sair,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: const Color(0xFFDC2626),
          ),
          child: Text(repo.demo ? '🚪 Sair do modo demonstração' : '🚪 Sair da conta',
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
