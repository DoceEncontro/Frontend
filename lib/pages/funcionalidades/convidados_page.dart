import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/services/amizade_service.dart';
import 'package:festora/services/convidado_service.dart';
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

  final baseUrl = dotenv.env['BASE_URL']?.replaceAll('%23', '#');

  @override
  void initState() {
    super.initState();
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
    final listaParticipantes = await EventoService().listarParticipantes(widget.evento.id);

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
               !listaParticipantes.any((participante) => participante.id == amigo.id);
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
      setState(() => _convidados = lista);
    } catch (_) {
      setState(() => _convidados = []);
    } finally {
      setState(() => _carregandoLista = false);
    }
  }

  Future<void> _adicionarConvidado() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Aqui você irá chamar o serviço que adiciona no banco (substituir por seu método real)
      await ConvidadoService().adicionarConvidado(nome, widget.evento.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convidado adicionado com sucesso!')),
      );
      _nomeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao adicionar convidado')),
      );
    } finally {
      await _carregarConvidados();
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
                          return ListTile(
                            leading: const Icon(Icons.person_add),
                            title: Text(amigo.nome),
                            onTap: () async {
                              Navigator.of(context).pop();
                              setState(() => _isLoading = true);
                              try {
                                await ConvidadoService().adicionarConvidado(
                                    amigo.nome, widget.evento.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('${amigo.nome} foi convidado!'),
                                  ),
                                );
                                await _carregarConvidados();
                                await carregarAmigosEParticipantes();
                              } catch (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Erro ao convidar o amigo.')),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                          );
                        },
                      ),
                    ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
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
                labelText: 'Nome do Convidado',
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
                    final baseUrl =
                        dotenv.env['BASE_URL']?.replaceAll('%23', '#') ?? '';
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
                  : _convidados.isEmpty
                      ? const Center(
                          child: Text(
                            '📌 Nenhum convidado encontrado.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _convidados.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(_convidados[index].nome),
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
