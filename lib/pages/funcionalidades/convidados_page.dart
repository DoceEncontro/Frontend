import 'package:festora/controllers/convidados_controller.dart';
import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/services/amizade_service.dart';
import 'package:festora/services/convidado_service.dart';
import 'package:festora/services/convite_service.dart';
import 'package:festora/services/evento_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConvidadosPage extends StatefulWidget {
  final EventoDetails evento;

  const ConvidadosPage({super.key, required this.evento});

  static const String routeName = 'convidados';

  @override
  State<ConvidadosPage> createState() => _ConvidadosPageState();
}

class _ConvidadosPageState extends State<ConvidadosPage> {
  final TextEditingController _nomeController = TextEditingController();
  bool _isLoading = false;
  bool _carregandoLista = true;
  bool _carregandoAmigos = false;
  List<String> _amigosSelecionados = [];
  List<Usuario> _convidadosFiltrados = [];

  late ConvidadosController convidadosController;

  final baseUrl = dotenv.env['BASE_URL']?.replaceAll('%23', '#');

  @override
  void initState() {
    super.initState();
    _nomeController.addListener(_filtrarConvidados); // <- escuta a digitação
    convidadosController =
        Provider.of<ConvidadosController>(context, listen: false);
    _carregarConvidados();
  }

  Future<void> carregarAmigosEParticipantes() async {
    setState(() {
      _carregandoAmigos = true;
    });
    if (!convidadosController.listasCarregadas) {
      try {
        final listaParticipantes =
            await EventoService().listarParticipantes(widget.evento.id);

        final listaAmigos = await AmizadeService().listarAceitos();

        convidadosController.setListas(listaAmigos, listaParticipantes);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar amigos.')),
        );
      }
    }
    setState(() {
      _carregandoAmigos = false;
    });
  }

  Future<void> _carregarConvidados() async {
    setState(() => _carregandoLista = true);
    if (convidadosController.convidadosCarregados) {
      setState(() {
        _convidadosFiltrados = convidadosController.convidados;
      });
    } else {
      try {
        final lista =
            await ConvidadoService().buscarConvidados(widget.evento.id);

        convidadosController.setConvidados(lista);

        setState(() {
          _convidadosFiltrados = lista;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar convidados.')),
        );
      }
    }
    setState(() => _carregandoLista = false);
  }

  void _filtrarConvidados() {
    final query = _nomeController.text.toLowerCase();
    setState(() {
      _convidadosFiltrados = convidadosController.amigos
          .where((convidado) => convidado.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _adicionarConvidados() async {
    if (_amigosSelecionados.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ConviteService()
          .enviarConvites(widget.evento.id, _amigosSelecionados);

      // Atualiza localmente as listas
      convidadosController.adicionarConvidados(_amigosSelecionados);

      setState(() {
        _convidadosFiltrados = convidadosController.convidados;
        _amigosSelecionados.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amigos convidados com sucesso!')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao convidar amigos')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> removerConvidado(String usuarioId) async {
    try {
      await ConviteService().removerConvite(widget.evento.id, usuarioId);

      convidadosController.excluirConvidadoPorId(usuarioId);

      setState(() {
        _convidadosFiltrados = convidadosController.convidados;
      });

      convidadosController.atualizarAmigosDisponiveis();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite removido com sucesso!')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover convite')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _abrirModalConvidarAmigos() async {
    if (convidadosController.amigos.isEmpty &&
        !convidadosController.listasCarregadas) {
      await carregarAmigosEParticipantes();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: const Text('Convidar Amigos'),
              content: _carregandoAmigos
                  ? const Center(child: CircularProgressIndicator())
                  : (convidadosController.listasCarregadas &&
                          convidadosController.amigos.isEmpty)
                      ? const Text(
                          'Você não possui amigos disponíveis para convite.')
                      : SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: convidadosController.amigos.length,
                            itemBuilder: (context, index) {
                              final amigo = convidadosController.amigos[index];
                              return CheckboxListTile(
                                value: _amigosSelecionados.contains(amigo.id),
                                title: Text(amigo.nome),
                                onChanged: (bool? selected) {
                                  setStateModal(() {
                                    if (selected == true) {
                                      _amigosSelecionados.add(amigo.id);
                                    } else {
                                      _amigosSelecionados.remove(amigo.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _amigosSelecionados.isEmpty
                      ? null
                      : () async {
                          Navigator.of(context).pop();
                          await _adicionarConvidados();
                        },
                  child: const Text('Convidar selecionados'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convidados'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar convidado',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.evento.isAutor == true)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _abrirModalConvidarAmigos,
                      icon: const Icon(Icons.add),
                      label: const Text('Convidar amigos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFADD8E6),
                        foregroundColor: Colors.black,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () {
                    final conviteUrl =
                        '$baseUrl/convite?eventoId=${widget.evento.id}';
                    final mensagem =
                        'Você está convidado para o ${widget.evento.tipo}, "${widget.evento.titulo}"! 🎉\n\nConfirme sua presença: $conviteUrl';

                    Share.share(mensagem);
                  },
                  icon: const Icon(Icons.share, color: Colors.pinkAccent),
                  label: const Text(
                    'Compartilhar',
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Convidados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _carregandoLista
                  ? const Center(child: CircularProgressIndicator())
                  : _convidadosFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            '📌 Nenhum convidado encontrado.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _convidadosFiltrados.length,
                          itemBuilder: (context, index) {
                            final convidado = _convidadosFiltrados[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(convidado.nome),
                              trailing: widget.evento.isAutor == true
                                  ? IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      tooltip: 'Remover convite',
                                      onPressed: () =>
                                          removerConvidado(convidado.id),
                                    )
                                  : null,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }
}
