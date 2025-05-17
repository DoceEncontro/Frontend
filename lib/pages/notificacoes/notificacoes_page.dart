import 'package:festora/utils/icone_helper.dart';
import 'package:flutter/material.dart';
import 'package:festora/services/notificacao_service.dart';
import 'package:festora/models/notificacao_model.dart';

class NotificationBubbleDialog extends StatefulWidget {
  const NotificationBubbleDialog({super.key});

  @override
  State<NotificationBubbleDialog> createState() => _NotificationBubbleDialogState();
}

class _NotificationBubbleDialogState extends State<NotificationBubbleDialog> {
  late Future<List<NotificacaoModel>> _notificacoesFuture;

  @override
  void initState() {
    super.initState();
    _notificacoesFuture = NotificacaoService().obterNotificacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Clica fora fecha
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
          ),
        ),

        // Balão com seta
        Positioned(
          top: 48,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 🔽 Setinha com controle da posição à direita (mantido igual seu original)
              Padding(
                padding: const EdgeInsets.only(right: 54),
                child: Align(
                  alignment: Alignment.topRight,
                  child: CustomPaint(
                    painter: _TrianglePainter(),
                    child: const SizedBox(height: 10, width: 20),
                  ),
                ),
              ),

              // 📦 Balão com notificações dinâmicas
              Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FutureBuilder<List<NotificacaoModel>>(
                    future: _notificacoesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Erro ao carregar notificações');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Nenhuma notificação');
                      }

                      final notificacoes = snapshot.data!;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Notificações',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),
                          ...notificacoes.map(
                            (n) => ListTile(
                              leading: Icon(IconeHelper.iconeFromString(n.icone)),
                              title: Text(n.titulo),
                              subtitle: Text(n.corpo),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white; // mantive cor branca como no seu código
    final path = Path()
      ..moveTo(0, size.height) // bottom left
      ..lineTo(size.width / 2, 0) // top center
      ..lineTo(size.width, size.height) // bottom right
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
