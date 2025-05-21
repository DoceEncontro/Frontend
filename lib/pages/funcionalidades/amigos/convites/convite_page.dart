import 'package:festora/controllers/convite_controller.dart';
import 'package:festora/controllers/evento_controller.dart';
import 'package:festora/models/convite_model.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/services/convite_service.dart';
import 'package:festora/services/evento_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConvitesModal extends StatefulWidget {
  const ConvitesModal({super.key});

  @override
  State<ConvitesModal> createState() => _ConvitesModalState();
}

class _ConvitesModalState extends State<ConvitesModal> {
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarConvites();
  }

  Future<void> carregarConvites() async {
    final conviteController =
        Provider.of<ConviteController>(context, listen: false);

    if (!conviteController.isCarregado) {
      try {
        final convitesRecebidos =
            await ConviteService().listarConvitesUsuario();
        conviteController.setconvites(convitesRecebidos);
      } catch (_) {
        // Pode mostrar erro se quiser
      }
    }

    setState(() => carregando = false);
  }

  Future<void> aceitarConvite(ConviteModel convite) async {
    final (sucesso, mensagem) =
        await EventoService().participar(convite.eventoId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );

      if (sucesso) {
        final eventoAceito =
            await EventoService().buscarEvento(convite.eventoId);
        Provider.of<EventoController>(context, listen: false)
            .adicionarEvento(EventoModel.fromDetails(eventoAceito.$2));

        // Remove convite da lista do controller
        Provider.of<ConviteController>(context, listen: false)
            .removerConvitePorId(convite.id);
      }
    }
  }

  Future<void> recusarConviteDoModal(String conviteId) async {
    try {
      await ConviteService().recusarConvite(conviteId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Convite recusado com sucesso.")),
        );

        Provider.of<ConviteController>(context, listen: false)
            .removerConvitePorId(conviteId);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao recusar convite.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conviteController = Provider.of<ConviteController>(context);

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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                      child: conviteController.convites.isEmpty
                          ? const Center(
                              child: Text('Nenhum convite recebido.'))
                          : ListView.builder(
                              itemCount: conviteController.convites.length,
                              itemBuilder: (context, index) {
                                final convite =
                                    conviteController.convites[index];
                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                aceitarConvite(convite);
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFA3E4D7),
                                              ),
                                              child: const Text('Aceitar',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () {
                                                recusarConviteDoModal(
                                                    convite.id);
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFF5B7B1),
                                              ),
                                              child: const Text('Negar',
                                                  style: TextStyle(
                                                      color: Colors.black)),
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
