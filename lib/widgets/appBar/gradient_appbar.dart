import 'package:festora/pages/funcionalidades/amigos/convites/convite_page.dart';
import 'package:flutter/material.dart';
import 'package:festora/services/token_service.dart';
import 'package:go_router/go_router.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String user;

  const GradientAppBar(this.user, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              // Saudação e data (à esquerda)
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
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

              // Ícones (à direita, no topo)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.mail,
                            color: Colors.amber, size: 26),
                        onPressed: () {
                          GoRouter.of(context)
                              .pushNamed(ConvitesPage.routeName);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.amber, size: 26),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Abrir notificações')),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings,
                            color: Colors.black, size: 28),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
