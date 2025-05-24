import 'dart:convert';

import 'package:festora/config/api_config.dart';
import 'package:festora/models/mensagem_model.dart';
import 'package:festora/utils/TokenHelper.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final baseUrl = '${ApiConfig.baseUrl}/eventos/chats/mensagens';

  Future<List<Mensagem>> obterMensagens(String chatId) async {
    final token = await TokenHelper.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Mensagem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar mensagens');
    }
  }
}
