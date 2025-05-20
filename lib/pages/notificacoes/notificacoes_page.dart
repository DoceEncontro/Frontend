import 'package:festora/controllers/notificacao_controller.dart';
import 'package:festora/utils/icone_helper.dart';
import 'package:flutter/material.dart';
import 'package:festora/services/notificacao_service.dart';
import 'package:festora/models/notificacao_model.dart';
import 'package:provider/provider.dart';

class NotificationBubbleDialog extends StatefulWidget {
  const NotificationBubbleDialog({super.key});

  @override
  State<NotificationBubbleDialog> createState() =>
      _NotificationBubbleDialogState();
}

class _NotificationBubbleDialogState extends State<NotificationBubbleDialog> {
  @override
  void initState() {
    super.initState();
    carregarNotificacoes();
  }

  Future<void> carregarNotificacoes() async {
    if (!Provider.of<NotificacaoController>(context, listen: false)
        .isCarregado) {
      try {
        List<NotificacaoModel> notificacoes =
            await NotificacaoService().obterNotificacoes();

        Provider.of<NotificacaoController>(context, listen: false)
            .setNotificacoes(notificacoes);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar notificações")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificacoes =
        Provider.of<NotificacaoController>(context).notificacoes;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Positioned(
          top: 48,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
                  child: Column(
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
                      if (notificacoes.isEmpty)
                        const ListTile(
                          leading: Icon(Icons.notifications_off),
                          title: Text('Nenhuma notificação'),
                        )
                      else
                        ...notificacoes.map(
                          (n) => ListTile(
                            leading: Icon(IconeHelper.iconeFromString(n.icone)),
                            title: Text(n.titulo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.corpo),
                                const SizedBox(height: 4),
                                Text(
                                  n.data,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        ),
                    ],
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
    final paint = Paint()
      ..color = Colors.white; // mantive cor branca como no seu código
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
