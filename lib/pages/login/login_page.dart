import 'package:festora/pages/help/help_page.dart';
import 'package:festora/pages/menu/home_page.dart';
import 'package:festora/pages/menu/home_section_page.dart';
import 'package:festora/utils/rota_anterior_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/login/register_page.dart';
import '../../services/login_service.dart';
import '../../services/token_service.dart';
import '../../models/login_model.dart';

const Color primaryColor = Color.fromARGB(255, 152, 103, 236);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String name = "LoginPage";

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _verificarToken();
  }

  Future<void> _verificarToken() async {
    bool autenticado = await TokenService.verificarToken(context);
    if (autenticado) {
      context.goNamed(HomeSectionPage.name);
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final login = _loginController.text;
    final senha = _senhaController.text;

    final sucesso = await LoginService().fazerLogin(LoginModel(
      email: login,
      senha: senha,
    ));

    setState(() {
      _isLoading = false;
    });

    if (sucesso == true) {
      final prefs = await SharedPreferences.getInstance();
      final String? rotaAnterior = prefs.getString("rota_anterior");
      if (rotaAnterior != null) {
        await prefs.remove("rota_anterior");
        context.go(rotaAnterior);
        
      } else {
      context.goNamed(HomeSectionPage.name);
      }
      
    } else {
      setState(() {
        _errorMessage = "Login ou senha incorretos";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login ou senha incorretos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE0F7FA),
                    Color.fromARGB(255, 202, 180, 238),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.1,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "DOCE ENCONTRO",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "PlayfairDisplay",
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: primaryColor.withOpacity(0.5),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    TextFormField(
                      controller: _loginController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon:
                            Icon(Icons.email_outlined, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon:
                            Icon(Icons.lock_outline, color: primaryColor),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 40),
                    const Divider(thickness: 1.5, color: Colors.black26),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.goNamed(RegisterPage.name),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade100,
                              foregroundColor: Colors.pink.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Cadastrar"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.goNamed(HelpPage.name);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Ajuda"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            // Widget para desenhar a borda gradiente
                            CustomPaint(
                              painter: GradientBorderPainter(
                                borderWidth: 2.0,
                                radius:
                                    8.0, // Aqui define o quão arredondado você quer
                              ),
                              size: const Size(60, 60),
                            ),
                            // Botão do Google sem borda
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: OutlinedButton(
                                onPressed: () {
                                  // TODO: Implementar login com Google
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide(
                                      color: Colors.transparent,
                                      width: 0), // Sem borda padrão
                                ),
                                child: Image.asset(
                                  'assets/images/google (1).png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implementar login com Apple
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                  color: Colors.black, width: 1.5),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.apple,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final double borderWidth;
  final double radius;

  GradientBorderPainter({
    required this.borderWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintTop = Paint()
      ..color = Colors.blue
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final paintRight = Paint()
      ..color = Colors.red
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final paintBottom = Paint()
      ..color = Colors.yellow.shade700
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final paintLeft = Paint()
      ..color = Colors.green
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final double left = borderWidth / 2;
    final double top = borderWidth / 2;
    final double right = size.width - borderWidth / 2;
    final double bottom = size.height - borderWidth / 2;

    final cornerRadius = Radius.circular(radius);

    // Top side
    final pathTop = Path()
      ..moveTo(left + radius, top)
      ..lineTo(right - radius, top)
      ..arcToPoint(
        Offset(right, top + radius),
        radius: cornerRadius,
        clockwise: true,
      );
    canvas.drawPath(pathTop, paintTop);

    // Right side
    final pathRight = Path()
      ..moveTo(right, top + radius)
      ..lineTo(right, bottom - radius)
      ..arcToPoint(
        Offset(right - radius, bottom),
        radius: cornerRadius,
        clockwise: true,
      );
    canvas.drawPath(pathRight, paintRight);

    // Bottom side
    final pathBottom = Path()
      ..moveTo(right - radius, bottom)
      ..lineTo(left + radius, bottom)
      ..arcToPoint(
        Offset(left, bottom - radius),
        radius: cornerRadius,
        clockwise: true,
      );
    canvas.drawPath(pathBottom, paintBottom);

    // Left side
    final pathLeft = Path()
      ..moveTo(left, bottom - radius)
      ..lineTo(left, top + radius)
      ..arcToPoint(
        Offset(left + radius, top),
        radius: cornerRadius,
        clockwise: true,
      );
    canvas.drawPath(pathLeft, paintLeft);
  }

  @override
  bool shouldRepaint(covariant GradientBorderPainter oldDelegate) {
    return oldDelegate.borderWidth != borderWidth ||
        oldDelegate.radius != radius;
  }
}
