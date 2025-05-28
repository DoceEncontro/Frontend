import 'package:festora/pages/login/login_page.dart';
import 'package:festora/pages/login/register_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RotaAnteriorUtils {
  static Future<void> setRota(BuildContext context) async {
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
  }

  static Future<void> redirecionar(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? rotaAnterior = prefs.getString("rota_anterior");

    if (rotaAnterior != null) {
      await prefs.remove("rota_anterior");
      context.go(rotaAnterior);
    } else {
      context.goNamed(LoginPage.name);
    }
  }
}
