import 'dart:convert';

import 'package:festora/config/api_config.dart';
import 'package:festora/models/notificacao_model.dart';
import 'package:festora/utils/TokenHelper.dart';
import 'package:http/http.dart' as http;

class NotificacaoService {
  final String baseUrl = '${ApiConfig.baseUrl}/usuarios/notificacoes';

  Future<List<NotificacaoModel>> obterNotificacoes() async {
    final token = await TokenHelper.getToken();
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return data.map((e) => NotificacaoModel.fromJson(e)).toList();
      } else {
        throw Exception("Erro ao listar notificações");
      }
    } catch (e) {
      print(e);
      throw Exception("Erro ao listar notificações");
    }
  }
}
