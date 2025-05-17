import 'package:festora/config/api_config.dart';
import 'package:festora/controllers/amigos_controller.dart';
import 'package:festora/controllers/usuario_controller.dart';
import 'package:festora/pages/login/login_page.dart';
import 'package:festora/pages/login/register_page.dart';
import 'package:festora/pages/menu/home_page.dart';
import 'package:festora/services/usuario_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<void> salvarToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> obterToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> removerToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<bool> verificarToken(BuildContext context) async {
    String? token = await TokenService.obterToken(); // <-- Aqui o ajuste

    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/verificarToken');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode != 200) {
      UsuarioController().limparUser();
      AmigosController().limparListas();

      final currentRoute = ModalRoute.of(context)?.settings.name;

      if (currentRoute != LoginPage.name &&
          currentRoute != RegisterPage.name &&
          currentRoute != null) {
        final currentRouteURI = GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            .uri
            .toString();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("rota_anterior", currentRouteURI);
      }
      _redirecionarParaLogin(context);
      return false;
    } else {
      return false;
    }
  }

  // Limpa o token salvo
  static Future<void> limparToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Faz o logout completo
  static Future<void> logout(BuildContext context) async {
    await limparToken();

    Provider.of<UsuarioController>(context, listen: false).limparUser();
    Provider.of<AmigosController>(context, listen: false).limparListas();
    context.goNamed(LoginPage.name);
  }

  // Redireciona para login, se não estiver já lá
  static void _redirecionarParaLogin(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != LoginPage.name && currentRoute != RegisterPage.name) {
      context.goNamed(LoginPage.name);
    }
  }
}
