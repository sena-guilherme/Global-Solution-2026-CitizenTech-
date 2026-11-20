import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:agrosync/repositories/api_exception.dart';
import 'package:agrosync/repositories/local_storage.dart';

class DiaClima {
  final DateTime data;
  final double maxima;
  final double minima;
  final double chuvaMm;
  final int probChuva; 
  final int codigo;

  const DiaClima({
    required this.data,
    required this.maxima,
    required this.minima,
    required this.chuvaMm,
    required this.probChuva,
    required this.codigo,
  });
}

class ClimaModel {
  final String local;
  final bool usouGps;
  final double latitude;
  final double longitude;
  final double temperatura;
  final double umidadeAr;
  final double ventoKmh;
  final int codigo;
  final List<DiaClima> dias;
  final DateTime atualizadoEm;
  final bool deCache;

  const ClimaModel({
    required this.local,
    required this.usouGps,
    required this.latitude,
    required this.longitude,
    required this.temperatura,
    required this.umidadeAr,
    required this.ventoKmh,
    required this.codigo,
    required this.dias,
    required this.atualizadoEm,
    this.deCache = false,
  });

  DiaClima get hoje => dias.first;

  static String descricao(int c) {
    if (c == 0) return 'Céu limpo';
    if (c <= 2) return 'Parcialmente nublado';
    if (c == 3) return 'Nublado';
    if (c == 45 || c == 48) return 'Neblina';
    if (c >= 51 && c <= 57) return 'Garoa';
    if (c >= 61 && c <= 67) return 'Chuva';
    if (c >= 71 && c <= 77) return 'Neve';
    if (c >= 80 && c <= 82) return 'Pancadas de chuva';
    if (c >= 95) return 'Tempestade';
    return 'Nublado';
  }

  static String emoji(int c) {
    if (c == 0) return '☀️';
    if (c <= 2) return '⛅';
    if (c == 3) return '☁️';
    if (c == 45 || c == 48) return '🌫️';
    if (c >= 51 && c <= 57) return '🌦️';
    if (c >= 61 && c <= 67) return '🌧️';
    if (c >= 80 && c <= 82) return '🌧️';
    if (c >= 95) return '⛈️';
    return '☁️';
  }
}

class ClimaRepository {
  static const _chaveCache = 'cache:clima_ultimo';

  static const _ufs = {
    'Acre': 'AC', 'Alagoas': 'AL', 'Amapá': 'AP', 'Amazonas': 'AM',
    'Bahia': 'BA', 'Ceará': 'CE', 'Distrito Federal': 'DF',
    'Espírito Santo': 'ES', 'Goiás': 'GO', 'Maranhão': 'MA',
    'Mato Grosso': 'MT', 'Mato Grosso do Sul': 'MS', 'Minas Gerais': 'MG',
    'Pará': 'PA', 'Paraíba': 'PB', 'Paraná': 'PR', 'Pernambuco': 'PE',
    'Piauí': 'PI', 'Rio de Janeiro': 'RJ', 'Rio Grande do Norte': 'RN',
    'Rio Grande do Sul': 'RS', 'Rondônia': 'RO', 'Roraima': 'RR',
    'Santa Catarina': 'SC', 'São Paulo': 'SP', 'Sergipe': 'SE', 'Tocantins': 'TO',
  };

  Future<ClimaModel> porCoordenadas(double lat, double lon, String nome,
      {bool gps = false}) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toStringAsFixed(4),
      'longitude': lon.toStringAsFixed(4),
      'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '3',
    });
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        throw ApiException('Serviço de clima indisponível (${res.statusCode}).');
      }
      final envelope = {
        'nome': nome,
        'gps': gps,
        'lat': lat,
        'lon': lon,
        'salvoEm': DateTime.now().toIso8601String(),
        'dados': jsonDecode(res.body),
      };
      await LocalStorage.instance.salvarCache(_chaveCache, jsonEncode(envelope));
      return _construir(envelope, deCache: false);
    } on TimeoutException {
      return _ultimoSalvoOuErro();
    } on SocketException {
      return _ultimoSalvoOuErro();
    } on http.ClientException {
      return _ultimoSalvoOuErro();
    }
  }

  ClimaModel? ultimoSalvo() {
    final bruto = LocalStorage.instance.lerCache(_chaveCache);
    if (bruto == null) return null;
    try {
      return _construir(jsonDecode(bruto) as Map<String, dynamic>, deCache: true);
    } catch (_) {
      return null;
    }
  }

  ClimaModel _ultimoSalvoOuErro() {
    final salvo = ultimoSalvo();
    if (salvo == null) {
      throw ApiException('Sem internet e sem dados salvos de clima.', semRede: true);
    }
    return salvo;
  }

  Future<ClimaModel> porMunicipio(String nome) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': nome.trim(),
      'count': '1',
      'language': 'pt',
      'countryCode': 'BR',
    });
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final resultados = json['results'] as List?;
      if (resultados == null || resultados.isEmpty) {
        throw ApiException('Município "$nome" não encontrado.');
      }
      final r = resultados.first as Map<String, dynamic>;
      final estado = r['admin1'] as String?;
      final uf = estado == null ? null : (_ufs[estado] ?? estado);
      final rotulo = uf == null ? r['name'] as String : '${r['name']} - $uf';
      return await porCoordenadas(
        (r['latitude'] as num).toDouble(), (r['longitude'] as num).toDouble(), rotulo);
    } on TimeoutException {
      throw ApiException('Sem conexão para buscar o município.', semRede: true);
    } on SocketException {
      throw ApiException('Sem conexão para buscar o município.', semRede: true);
    } on http.ClientException {
      throw ApiException('Sem conexão para buscar o município.', semRede: true);
    }
  }

  Future<({double lat, double lon})> posicaoAtual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw ApiException('O GPS está desligado. Ative a localização do aparelho.');
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      throw ApiException(
          'Permissão de localização negada. Informe a localização manualmente.');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return (lat: pos.latitude, lon: pos.longitude);
  }

  Future<ClimaModel> porGps() async {
    final pos = await posicaoAtual();
    final nome = await _nomeDoLocal(pos.lat, pos.lon);
    return porCoordenadas(pos.lat, pos.lon, nome, gps: true);
  }

  Future<double?> temperaturaAtual(double lat, double lon) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': lat.toStringAsFixed(4),
        'longitude': lon.toStringAsFixed(4),
        'current': 'temperature_2m',
        'timezone': 'auto',
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final atual = (jsonDecode(res.body) as Map<String, dynamic>)['current']
          as Map<String, dynamic>?;
      return (atual?['temperature_2m'] as num?)?.toDouble();
    } catch (_) {
      return null;
    }
  }

  Future<String> _nomeDoLocal(double lat, double lon) async {
    try {
      final uri = Uri.https('api.bigdatacloud.net', '/data/reverse-geocode-client', {
        'latitude': lat.toStringAsFixed(4),
        'longitude': lon.toStringAsFixed(4),
        'localityLanguage': 'pt',
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final cidade = (json['city'] as String?)?.trim().isNotEmpty == true
          ? json['city'] as String
          : json['locality'] as String?;
      final uf = (json['principalSubdivisionCode'] as String?)?.split('-').last;
      if (cidade != null && cidade.isNotEmpty) {
        return uf == null ? cidade : '$cidade - $uf';
      }
    } catch (_) {
      // sem nome: usa o texto padrão
    }
    return 'Minha localização';
  }

  ClimaModel _construir(Map<String, dynamic> envelope, {required bool deCache}) {
    final dados = envelope['dados'] as Map<String, dynamic>;
    final atual = dados['current'] as Map<String, dynamic>;
    final diario = dados['daily'] as Map<String, dynamic>;
    final datas = (diario['time'] as List).cast<String>();

    num? valor(String chave, int i) => (diario[chave] as List)[i] as num?;

    final dias = <DiaClima>[
      for (var i = 0; i < datas.length; i++)
        DiaClima(
          data: DateTime.parse(datas[i]),
          maxima: valor('temperature_2m_max', i)?.toDouble() ?? 0,
          minima: valor('temperature_2m_min', i)?.toDouble() ?? 0,
          chuvaMm: valor('precipitation_sum', i)?.toDouble() ?? 0,
          probChuva: valor('precipitation_probability_max', i)?.toInt() ?? 0,
          codigo: valor('weather_code', i)?.toInt() ?? 0,
        ),
    ];
    return ClimaModel(
      local: envelope['nome'] as String,
      usouGps: (envelope['gps'] as bool?) ?? false,
      latitude: (envelope['lat'] as num).toDouble(),
      longitude: (envelope['lon'] as num).toDouble(),
      temperatura: (atual['temperature_2m'] as num).toDouble(),
      umidadeAr: (atual['relative_humidity_2m'] as num).toDouble(),
      ventoKmh: (atual['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      codigo: (atual['weather_code'] as num).toInt(),
      dias: dias,
      atualizadoEm: DateTime.parse(envelope['salvoEm'] as String),
      deCache: deCache,
    );
  }
}
