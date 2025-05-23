import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:8080'
      : dotenv.env['BACK_URL'] ?? '';
      //   : 'http://192.168.15.75:8080'; // victor pc
      // : 'http://192.168.71.222:8080'; // victor notebook
}

class ApiConfigChatbot {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:5005'
      : dotenv.env['CHATBOT_URL'] ?? '';
}