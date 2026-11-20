import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosync/models/produtor_model.dart';

class LocalStorage {
  LocalStorage._(this._prefs);

  static late LocalStorage instance;
  final SharedPreferences _prefs;

  /// 10.0.2.2 é o "localhost" do computador visto pelo emulador Android.
  static const String urlPadrao = 'http://10.0.2.2:8080';

  static Future<void> init() async {
    instance = LocalStorage._(await SharedPreferences.getInstance());
  }

  ThemeMode get themeMode {
    switch (_prefs.getString('tema')) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> salvarTema(ThemeMode modo) =>
      _prefs.setString('tema', modo.name);

  double get textScale => _prefs.getDouble('escala_texto') ?? 1.0;
  Future<void> salvarEscalaTexto(double v) =>
      _prefs.setDouble('escala_texto', v);

  String get fonte => _prefs.getString('fonte') ?? 'padrao';
  Future<void> salvarFonte(String f) => _prefs.setString('fonte', f);

  bool get onboardingVisto => _prefs.getBool('onboarding_visto') ?? false;
  Future<void> marcarOnboardingVisto() =>
      _prefs.setBool('onboarding_visto', true);

  String get apiUrl => _prefs.getString('api_url') ?? urlPadrao;
  Future<void> salvarApiUrl(String url) => _prefs.setString('api_url', url);

  String? get token => _prefs.getString('token');
  bool get demo => _prefs.getBool('demo') ?? false;

  Produtor? get usuario {
    final bruto = _prefs.getString('usuario');
    return bruto == null ? null : Produtor.fromJsonString(bruto);
  }

  Future<void> salvarSessao(
      {String? token, required Produtor usuario, required bool demo}) async {
    if (token != null) {
      await _prefs.setString('token', token);
    } else {
      await _prefs.remove('token');
    }
    await _prefs.setString('usuario', usuario.toJsonString());
    await _prefs.setBool('demo', demo);
  }

  Future<void> limparSessao() async {
    await _prefs.remove('token');
    await _prefs.remove('usuario');
    await _prefs.remove('demo');
    await _prefs.remove('confirmados');
    final modos = _prefs.getKeys().where((k) => k.startsWith('modo_irrig_')).toList();
    for (final k in modos) {
      await _prefs.remove(k);
    }
    final chaves =
        _prefs.getKeys().where((k) => k.startsWith('cache:')).toList();
    for (final k in chaves) {
      await _prefs.remove(k);
    }
  }

  bool irrigacaoAutomatica(int areaId) => _prefs.getBool('modo_irrig_$areaId') ?? true;
  Future<void> salvarIrrigacaoAutomatica(int areaId, bool automatica) =>
    _prefs.setBool('modo_irrig_$areaId', automatica);

  Set<int> get confirmados =>
    (_prefs.getStringList('confirmados') ?? const <String>[]).map(int.parse).toSet();
  Future<void> salvarConfirmado(int publicacaoId, bool confirmado) {
    final conjunto = confirmados;
    confirmado ? conjunto.add(publicacaoId) : conjunto.remove(publicacaoId);
    return _prefs.setStringList('confirmados', conjunto.map((e) => '$e').toList());
  }

  Future<void> salvarCache(String chave, String json) =>
      _prefs.setString(chave, json);
  String? lerCache(String chave) => _prefs.getString(chave);

  String get ultimaRegiao => _prefs.getString('ultima_regiao') ?? '';
  Future<void> salvarUltimaRegiao(String r) =>
      _prefs.setString('ultima_regiao', r);
}
