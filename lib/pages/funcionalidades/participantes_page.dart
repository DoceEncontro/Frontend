import 'package:festora/controllers/convidados_controller.dart';
import 'package:festora/controllers/evento_controller.dart';
import 'package:festora/controllers/participantes_controller.dart';
import 'package:festora/controllers/presente_controller.dart';
import 'package:festora/controllers/usuario_controller.dart';
import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/usuario_details_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/pages/menu/home_page.dart';
import 'package:festora/pages/menu/home_section_page.dart';
import 'package:festora/services/evento_service.dart';
import 'package:festora/services/usuario_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ParticipantesPage extends StatefulWidget {
  final EventoDetails evento;

  const ParticipantesPage({super.key, required this.evento});

  static const String routeName = 'participantes';

  @override
  State<ParticipantesPage> createState() => _ParticipantesPageState();
}

class _ParticipantesPageState extends State<ParticipantesPage> {
  final TextEditingController _pesquisaController = TextEditingController();
  bool _carregando = true;

  late ParticipantesController participantesController;
  late ConvidadosController convidadosController;

  List<Usuario> _participantesFiltrados = [];

  @override
  void initState() {
    super.initState();
    _pesquisaController.addListener(_filtrarParticipantes);
    participantesController =
        Provider.of<ParticipantesController>(context, listen: false);
    convidadosController =
        Provider.of<ConvidadosController>(context, listen: false);
    _carregarParticipantes();
  }

  Future<void> _carregarParticipantes() async {
    if (!participantesController.isCarregado) {
      setState(() => _carregando = true);
      try {
        final lista =
            await EventoService().listarParticipantes(widget.evento.id);

        // Organizar a lista colocando o organizador no topo
        lista.sort((a, b) {
          if (a.id == widget.evento.organizador.id)
            return -1; // Organizador no topo
          if (b.id == widget.evento.organizador.id) return 1;
          return 0;
        });

        participantesController.setParticipantes(lista);

        setState(() {
          _participantesFiltrados = lista;
        });
      } catch (_) {
        setState(() {
          _participantesFiltrados = [];
        });
      }
    } else {
      setState(() {
        _participantesFiltrados = participantesController.participantes;
      });
    }
    setState(() => _carregando = false);
  }

  void _filtrarParticipantes() {
    final query = _pesquisaController.text.toLowerCase();
    setState(() {
      _participantesFiltrados = participantesController.participantes
          .where((p) => p.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> removerParticipante(String usuarioId) async {
    setState(() => _carregando = true);
    try {
      // Tenta retirar o participante da lista do evento
      (bool, String) response = await EventoService()
          .retirarParticipante(widget.evento.id, usuarioId);

      if (response.$1) {
      final participanteRemovido = participantesController.participantes.firstWhere(
        (p) => p.id == usuarioId,
      );


        convidadosController.adicionarAmigosDisponiveis(participanteRemovido);
      

        participantesController.excluirParticipantePorId(usuarioId);

        setState(() {
          _participantesFiltrados = participantesController.participantes;
        });
      }
    } catch (_) {
      // Caso ocorra um erro, limpa as listas
      setState(() {
        _participantesFiltrados = [];
      });
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> confirmarRemocaoParticipante(
      BuildContext context, String usuarioId) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remover Participante"),
        content: const Text(
            "Tem certeza que deseja remover este participante do evento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Remover", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      await removerParticipante(usuarioId);
    }
  }

  Future<void> confirmarSaidaEvento(BuildContext context) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair do Evento"),
        content: const Text("Tem certeza que deseja sair deste evento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sair", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      final response = await EventoService().sairEvento(widget.evento.id);

      if (response.$1) {
        Provider.of<EventoController>(context, listen: false)
            .excluirEventoPorId(widget.evento.id);
        if (context.mounted) {
          GoRouter.of(context).goNamed(HomeSectionPage.name);
        }
      } else {
        String responseText = response.$2;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseText)),
        );
      }
    }
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioController>(context).usuario;
    final participantes =
        Provider.of<ParticipantesController>(context).participantes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _pesquisaController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar participante',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Título alinhado à esquerda
            const Text(
              'Participantes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _participantesFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            '📌 Nenhum participante encontrado.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _participantesFiltrados.length,
                          itemBuilder: (context, index) {
                            final participante = _participantesFiltrados[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(participante.nome),
                                        if (participante.id ==
                                            widget.evento.organizador.id)
                                          const Text(
                                            'Organizador',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 157, 32, 148),
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (widget.evento.isAutor &&
                                      participante.id !=
                                          widget.evento.organizador.id)
                                    TextButton.icon(
                                      onPressed: () =>
                                          confirmarRemocaoParticipante(
                                              context, participante.id),
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      label: const Text("Remover",
                                          style: TextStyle(color: Colors.red)),
                                    )
                                  else if (usuario!.id == participante.id &&
                                      participante.id !=
                                          widget.evento.organizador.id)
                                    TextButton.icon(
                                      onPressed: () =>
                                          confirmarSaidaEvento(context),
                                      icon: const Icon(Icons.exit_to_app,
                                          color: Colors.red),
                                      label: const Text("Sair",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
