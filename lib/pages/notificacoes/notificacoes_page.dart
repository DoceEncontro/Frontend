import 'package:flutter/material.dart';

class NotificationBubbleDialog extends StatelessWidget {
  const NotificationBubbleDialog({super.key});

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
                // 🔽 Setinha com controle da posição à direita
                Padding(
                  padding: const EdgeInsets.only(right: 54), // ajuste aqui
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CustomPaint(
                      painter: _TrianglePainter(),
                      child: const SizedBox(height: 10, width: 20),
                    ),
                  ),
                ),

                // 📦 Balão
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
                      children: const [
                        Text(
                          'Notificações',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.mail),
                          title: Text('Novo convite recebido'),
                        ),
                        ListTile(
                          leading: Icon(Icons.event),
                          title: Text('Evento começa amanhã'),
                        ),
                        ListTile(
                          leading: Icon(Icons.message),
                          title: Text('Nova mensagem de João'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
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
