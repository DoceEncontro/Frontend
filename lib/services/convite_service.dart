import 'dart:convert';
import 'package:festora/config/api_config.dart';
import 'package:festora/models/convite_model.dart';
import 'package:http/http.dart' as http;
import 'package:festora/services/token_service.dart';

class ConviteService {
  final String baseUrl = '${ApiConfig.baseUrl}/eventos/convites';
  final String baseUrlUsuario = '${ApiConfig.baseUrl}/usuarios/convites';

  Future<void> enviarConvites(String eventoId, List<String> usuariosIds) async {
    final token = await TokenService.obterToken();

    final response = await http.post(
      Uri.parse('$baseUrl/$eventoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(usuariosIds),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao enviar convites');
    }
  }

  Future<void> removerConvite(String eventoId, String usuarioId) async {
    final token = await TokenService.obterToken();

    final response =
        await http.delete(Uri.parse('$baseUrl/$eventoId/$usuarioId'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao remover convites');
    }
  }

  Future<List<ConviteModel>> listarConvitesUsuario() async {
    final token = await TokenService.obterToken();

    try {
      final response = await http.get(
        Uri.parse(baseUrlUsuario),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return data.map((e) => ConviteModel.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao listar convites recebidos');
      }
    } catch (e) {
      throw Exception("Erro ao listar notificações");
    }
  }
}
