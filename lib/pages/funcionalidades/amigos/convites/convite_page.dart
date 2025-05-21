import 'package:flutter/material.dart';
import 'package:festora/models/convite_model.dart';
import 'package:festora/services/convite_service.dart';

class ConvitesModal extends StatefulWidget {
  const ConvitesModal({super.key});

  @override
  State<ConvitesModal> createState() => _ConvitesModalState();
}

class _ConvitesModalState extends State<ConvitesModal> {
  List<ConviteModel> convites = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarConvites();
  }

  Future<void> carregarConvites() async {
    try {
      final convitesRecebidos = await ConviteService().listarConvitesUsuario();
      setState(() {
        convites = convitesRecebidos;
        carregando = false;
      });
    } catch (_) {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.65,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: carregando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '📬 Convites Recebidos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: convites.isEmpty
                          ? const Center(child: Text('Nenhum convite recebido.'))
                          : ListView.builder(
                              itemCount: convites.length,
                              itemBuilder: (context, index) {
                                final convite = convites[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          convite.titulo,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(convite.descricao),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                // TODO: Aceitar convite
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: const Color(0xFFA3E4D7),
                                              ),
                                              child: const Text('Aceitar', style: TextStyle(color: Colors.black)),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () {
                                                // TODO: Negar convite
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: const Color(0xFFF5B7B1),
                                              ),
                                              child: const Text('Negar', style: TextStyle(color: Colors.black)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
