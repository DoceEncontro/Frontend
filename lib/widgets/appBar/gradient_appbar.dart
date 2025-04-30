import 'package:flutter/material.dart';
import 'package:festora/services/token_service.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String user;

  const GradientAppBar(this.user, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // 👈 Adiciona margem superior segura
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3F3F3),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              offset: Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Saudação e data
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Olá, $user!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Notificações
            Positioned(
              top: 12,
              right: 56,
              child: IconButton(
                icon: const Icon(Icons.notifications,
                    color: Colors.amber, size: 26),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir notificações')),
                  );
                },
              ),
            ),

            // Configurações
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.settings, color: Colors.black, size: 28),
                onSelected: (String result) {
                  if (result == 'config') {
                    // ação futura
                  } else if (result == 'logout') {
                    TokenService.logout(context);
                  }
                },
                itemBuilder: (BuildContext context) => const [
                  PopupMenuItem<String>(
                    value: 'config',
                    child: Text('Configurações'),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Sair'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
