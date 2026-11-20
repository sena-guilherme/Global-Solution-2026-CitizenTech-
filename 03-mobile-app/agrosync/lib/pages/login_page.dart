import 'package:flutter/material.dart';

import 'package:agrosync/repositories/api_repository.dart';
import 'package:agrosync/theme/app_theme.dart';
import 'package:agrosync/utils/imagens.dart';
import 'package:agrosync/widgets/app_header.dart';
import 'package:agrosync/widgets/custom_button.dart';
import 'package:agrosync/widgets/foto_slot.dart';
import 'package:agrosync/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _municipio = TextEditingController();
  final _regiao = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _modoCadastro = false;
  bool _carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _nome.dispose();
    _municipio.dispose();
    _regiao.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _irParaApp() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final repo = ApiRepository.instance;
      final email = _email.text.trim();
      if (_modoCadastro) {
        await repo.registrar(
          nome: _nome.text.trim(),
          email: email,
          senha: _senha.text,
          municipio: _municipio.text.trim(),
          regiao: _regiao.text.trim(),
        );
      } else {
        await repo.login(email, _senha.text);
      }
      if (!mounted) return;
      _irParaApp();
    } on ApiException catch (e) {
      if (!mounted) return;
      await _mostrarErro(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _mostrarErro(ApiException e) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_modoCadastro ? 'Não foi possível cadastrar' : 'Não foi possível entrar'),
        content: Text(e.semRede
            ? '${e.mensagem}\n\nUse o modo demonstração para testar o app.'
            : e.mensagem),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _modoDemo() async {
    await ApiRepository.instance.entrarModoDemo();
    if (!mounted) return;
    _irParaApp();
  }

  Widget _rotulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 14),
        child: Text(texto,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    final p = Paleta.of(context);
    return Scaffold(
      backgroundColor: p.card,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FotoSlot(
                            slot: Imagens.loginTopo,
                            altura: 130,
                            raio: 20,
                            escurecer: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.verdeProfundo.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Image.asset(
                              'assets/imagens/logo.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const LogoTile(tamanho: 60, emoji: '🌾', claro: true),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _modoCadastro
                                ? 'Crie sua conta'
                                : 'Bem-vindo(a) ao AgroSync',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _modoCadastro
                                ? 'Cadastre-se para receber alertas da sua lavoura.'
                                : 'Faça login rápido para acessar seus dados de plantio e alertas no campo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5, color: p.mudo),
                          ),
                          const SizedBox(height: 18),
                          // Atalho para usar o app sem servidor.
                          OutlinedButton(
                            onPressed: _carregando ? null : _modoDemo,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: p.card,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🧪', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 10),
                                Text('Entrar em modo demonstração',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(child: Divider(color: p.borda)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('OU COM E-MAIL',
                                    style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: p.mudo)),
                              ),
                              Expanded(child: Divider(color: p.borda)),
                            ],
                          ),
                          if (_modoCadastro) ...[
                            _rotulo('Seu Nome'),
                            TextFormField(
                              controller: _nome,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(hintText: 'Ex: João da Silva'),
                              validator: (v) => (v == null || v.trim().length < 3)
                                  ? 'Informe seu nome'
                                  : null,
                            ),
                          ],
                          _rotulo('E-mail'),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration:
                                const InputDecoration(hintText: 'exemplo@email.com'),
                            validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(v?.trim() ?? '')
                                ? null
                                : 'E-mail inválido',
                          ),
                          _rotulo('Senha'),
                          TextFormField(
                            controller: _senha,
                            obscureText: _ocultarSenha,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              suffixIcon: IconButton(
                                icon: Icon(_ocultarSenha
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _ocultarSenha = !_ocultarSenha),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Mínimo de 6 caracteres'
                                : null,
                          ),
                          if (_modoCadastro) ...[
                            _rotulo('Município'),
                            TextFormField(
                              controller: _municipio,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(hintText: 'Ex: Piedade'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Informe o município'
                                  : null,
                            ),
                            _rotulo('Região'),
                            TextFormField(
                              controller: _regiao,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(hintText: 'Ex: Sorocaba'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Informe a região'
                                  : null,
                            ),
                          ],
                          const SizedBox(height: 20),
                          CustomButton(
                            label: _modoCadastro ? 'Criar conta' : 'Entrar no Aplicativo',
                            carregando: _carregando,
                            onPressed: _enviar,
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: _carregando
                                ? null
                                : () => setState(() => _modoCadastro = !_modoCadastro),
                            child: Text(
                              _modoCadastro
                                  ? 'Já tenho conta — entrar'
                                  : 'Não tenho conta — cadastrar',
                              style: const TextStyle(
                                  color: AppTheme.verde, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
              child: Text(
                'FIAP • Global Solution 2026/2 • CitizenTech',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: p.mudo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}