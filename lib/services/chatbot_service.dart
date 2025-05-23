import 'dart:convert';

import 'package:festora/config/api_config.dart';
import 'package:festora/models/chatbot_model.dart'; // supondo que ChatbotResponse está aqui
import 'package:festora/utils/TokenHelper.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  static final String baseUrl = '${ApiConfigChatbot.baseUrl}/webhooks/rest/webhook';

  Future<List<ChatbotResponse>> enviarMensagem(UserMessage userMessage) async {
    final token = await TokenHelper.getToken();

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userMessage.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ChatbotResponse.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao enviar mensagem: ${response.statusCode}');
      }
    } catch (e) {
      // Aqui você pode criar uma exception customizada para tratar erros específicos
      rethrow;
    }
  }
}
