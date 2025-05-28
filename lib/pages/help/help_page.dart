import 'package:festora/pages/funcionalidades/chatbot_modal.dart';
import 'package:festora/pages/login/login_page.dart';
import 'package:festora/utils/rota_anterior_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; // <- Importante

const Color primaryColor = Color.fromARGB(255, 152, 103, 236);

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  static const String name = 'HelpPage';

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  // Número e email de suporte fictícios
  final String _whatsappNumber = '+5511999999999';
  final String _supportEmail = 'suporte@festora.com';

  Future<void> _openWhatsApp() async {
    final whatsappUrl = Uri.parse("https://wa.me/$_whatsappNumber");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      _showError('Não foi possível abrir o WhatsApp.');
    }
  }

  Future<void> _sendEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query:
          'subject=Ajuda com o app Festora&body=Olá, preciso de ajuda com...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showError('Não foi possível abrir o aplicativo de e-mail.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: const Text(
          'Ajuda',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => {
            RotaAnteriorUtils.redirecionar(context),
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: null, // Desativa o botão
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade100,
                foregroundColor: Colors.pink.shade800,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.lock_reset),
              label: const Text(
                'Recuperar Senha',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade800,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.chat),
              label: const Text(
                'Falar com suporte (WhatsApp)',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _sendEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade800,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.email_outlined),
              label: const Text(
                'Entrar em contato (E-mail)',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => ChatbotScreen(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade100,
                foregroundColor: Colors.purple.shade800,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.smart_toy_outlined),
              label: const Text(
                'Falar com Chatbot',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
