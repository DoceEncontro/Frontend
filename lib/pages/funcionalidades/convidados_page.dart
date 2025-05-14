import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/services/amizade_service.dart';
import 'package:festora/services/convidado_service.dart';
import 'package:festora/services/convite_service.dart';
import 'package:festora/services/evento_service.dart';
import 'package:flutter/material.dart';
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
  List<Usuario> _convidados = []; // apenas nomes por enquanto
  List<Usuario> _amigos = []; // apenas nomes por enquanto
  List<Usuario> _participantes = [];
  bool _carregandoLista = true;
  bool _carregandoAmigos = false;
  bool _nenhumAmigo = false;
  List<String> _amigosSelecionados = [];
  List<Usuario> _convidadosFiltrados = [];

  final baseUrl = dotenv.env['BASE_URL']?.replaceAll('%23', '#');

  @override
  void initState() {
    super.initState();
        _nomeController.addListener(_filtrarConvidados); // <- escuta a digitação
    _carregarConvidados();
  }

  Future<void> carregarAmigosEParticipantes() async {
    if (_nenhumAmigo) return; // já sabemos que não tem amigos

    setState(() {
      _carregandoAmigos = true;
      _carregandoLista = true; // Inicia o carregamento dos participantes também
    });

    try {
      // Carregar a lista de participantes
      final listaParticipantes =
          await EventoService().listarParticipantes(widget.evento.id);

      // Carregar a lista de amigos aceitos
      final listaAmigos = await AmizadeService().listarAceitos();

      // Caso não haja amigos, defina a flag
      if (listaAmigos.isEmpty) {
        _nenhumAmigo = true;
        _amigos = [];
      } else {
        // Filtra amigos que não estão na lista de convidados e não são participantes
        final amigosFiltrados = listaAmigos.where((amigo) {
          // Verifica se o amigo não está na lista de convidados e nem na lista de participantes
          return !_convidados.any((convidado) => convidado.id == amigo.id) &&
              !listaParticipantes
                  .any((participante) => participante.id == amigo.id);
        }).toList();

        setState(() {
          _amigos = amigosFiltrados;
          if (_amigos.isEmpty) _nenhumAmigo = true; // todos já convidados
        });
      }

      // Adicionar participantes à lista _participantes
      setState(() {
        _participantes = listaParticipantes;
      });
    } catch (_) {
      setState(() {
        _amigos = [];
        _participantes = [];
      });
    } finally {
      setState(() {
        _carregandoAmigos = false;
        _carregandoLista = false; // Finaliza o carregamento dos participantes
      });
    }
  }

  Future<void> _carregarConvidados() async {
    setState(() => _carregandoLista = true);
    try {
      // Aqui você deve buscar os nomes dos convidados do backend
      // Por enquanto, vamos simular com dados fictícios:
      final lista =
          await ConvidadoService().buscarConvidados(widget.evento.id!);
      setState(() {
        _convidados = lista;
        _convidadosFiltrados = lista;
      });
    } catch (_) {
      setState(() => _convidados = []);
    } finally {
      setState(() => _carregandoLista = false);
    }
  }

  void _filtrarConvidados() {
  final query = _nomeController.text.toLowerCase();
  setState(() {
    _convidadosFiltrados = _convidados
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
      final convidadosNovos = _amigos
          .where((amigo) => _amigosSelecionados.contains(amigo.id))
          .toList();

      setState(() {
        _amigos.removeWhere((amigo) => _amigosSelecionados.contains(amigo.id));
        _convidados.addAll(convidadosNovos);
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

      setState(() {
        _convidados.removeWhere((convidado) => convidado.id == usuarioId);
      });

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
    if (_amigos.isEmpty && !_nenhumAmigo) {
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
                  : (_nenhumAmigo || _amigos.isEmpty)
                      ? const Text(
                          'Você não possui amigos disponíveis para convite.')
                      : SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _amigos.length,
                            itemBuilder: (context, index) {
                              final amigo = _amigos[index];
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
