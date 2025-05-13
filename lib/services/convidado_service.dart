import 'dart:convert';
import 'package:festora/config/api_config.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/services/token_service.dart';
import 'package:http/http.dart' as http;

class ConvidadoService {
  final String baseUrl = '${ApiConfig.baseUrl}/eventos/convites'; // ajuste se necessário

  Future<void> adicionarConvidado(String nome, String eventoId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'eventoId': eventoId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar convidado');
    }
  }

  Future<List<Usuario>> buscarConvidados(String eventoId) async {
    final token = await TokenService.obterToken();

    final response = await http.get(
      Uri.parse('$baseUrl/$eventoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);
      return dados.map((item) => Usuario.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar convidados');
    }
  }
}
