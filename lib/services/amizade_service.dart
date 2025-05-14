import 'dart:convert';
import 'package:festora/models/usuario_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:festora/services/token_service.dart';
import 'package:festora/config/api_config.dart';

class AmizadeService {
  final String baseUrl = '${ApiConfig.baseUrl}/usuarios/amizades';

  Future<void> enviarSolicitacao(String email) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/$email'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao enviar solicitação');
      }
    } catch (e) {
      print('Erro em enviarSolicitacao: $e');
      rethrow;
    }
  }

  Future<void> aceitarSolicitacao(String amizadeId) async {
    try {
      final response = await http
          .put(Uri.parse('$baseUrl/$amizadeId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Erro ao aceitar pedido');
      }
    } catch (e) {
      print('Erro em aceitarSolicitacao: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listarPendentes() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/pendentes'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Erro ao listar pendentes');
      }
    } catch (e) {
      print('Erro em listarPendentes: $e');
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
      final List<dynamic> dados = jsonDecode(response.body);
      return dados.map((item) => Usuario.fromJson(item['amigo'])).toList();
    } else {
      throw Exception('Erro ao buscar convidados');
    }
  }
}
