import 'dart:convert';
import 'package:festora/exceptions/api_error_exception.dart';
import 'package:festora/models/amigo_model.dart';
import 'package:festora/models/api_error_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:festora/services/token_service.dart';
import 'package:festora/config/api_config.dart';

class AmizadeService {
  final String baseUrl = '${ApiConfig.baseUrl}/usuarios/amizades';

  Future<Amigo> enviarSolicitacao(String email) async {
    final url = Uri.parse('$baseUrl/$email');
    final token = await TokenService.obterToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic dados = jsonDecode(response.body);
      return Amigo.fromJson(dados);
    } else {
      try {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final apiError = ApiError.fromJson(json);
        throw ApiException(apiError);
      } catch (e) { 
        if (e is ApiException) rethrow;
        throw Exception('Erro ao enviar solicitação: ${response.statusCode}');
      }
    }
  }

  Future<void> aceitarSolicitacao(String amizadeId) async {
    try {
      final url = Uri.parse('$baseUrl/$amizadeId');
      final token = await TokenService.obterToken();

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao aceitar pedido');
      }
    } catch (e) {
      print('Erro em aceitarSolicitacao: $e');
      rethrow;
    }
  }

  Future<void> excluirAmizade(String amizadeId) async {
    try {
      final url = Uri.parse('$baseUrl/$amizadeId');
      final token = await TokenService.obterToken();

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao excluir amizade');
      }
    } catch (e) {
      print('Erro em excluir amizade: $e');
      rethrow;
    }
  }

  Future<List<Amigo>> listarPendentes() async {
    try {
      final url = Uri.parse('$baseUrl/pendentes');
      final token = await TokenService.obterToken();

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return dados.map((item) => Amigo.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao listar pendentes');
      }
    } catch (e) {
      print('Erro em listarPendentes: $e');
      rethrow;
    }
  }

  Future<List<Amigo>> listarRecebidos() async {
    try {
      final url = Uri.parse('$baseUrl/recebidos');
      final token = await TokenService.obterToken();

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return dados.map((item) => Amigo.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao listar recebidos');
      }
    } catch (e) {
      print('Erro em listar recebidos: $e');
      rethrow;
    }
  }

  Future<List<Usuario>> listarAceitos() async {
    final url = Uri.parse(baseUrl);
    final token = await TokenService.obterToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
      return dados.map((item) => Usuario.fromJson(item['amigo'])).toList();
    } else {
      throw Exception('Erro ao buscar convidados');
    }
  }

  Future<List<Amigo>> listarAmigosAceitos() async {
    final url = Uri.parse(baseUrl);
    final token = await TokenService.obterToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
      return dados.map((item) => Amigo.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar amizades');
    }
  }
}
