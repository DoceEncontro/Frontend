import 'package:festora/controllers/usuario_controller.dart';
import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/mensagem_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatEventoPage extends StatefulWidget {
  static const String name = 'chat-evento';
  final EventoDetails evento;

  const ChatEventoPage({required this.evento, super.key});

  @override
  State<ChatEventoPage> createState() => _ChatEventoPageState();
}

class _ChatEventoPageState extends State<ChatEventoPage> {
  final TextEditingController _mensagemController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Mensagem> mensagens = [];
  bool carregando = true;

  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
  }

  Future<void> _carregarMensagens() async {
    setState(() => carregando = true);
    try {
      // Passar o id do chat, pode ser o id do evento por exemplo
      final lista = await _chatService.obterMensagens(widget.evento.chatId);
      setState(() {
        mensagens = lista;
        carregando = false;
      });
      _scrollParaFim();
    } catch (e) {
      setState(() => carregando = false);
      // Aqui você pode mostrar um snackbar ou alerta
      debugPrint('Erro ao carregar mensagens: $e');
    }
  }

  void enviarMensagem() {
    final texto = _mensagemController.text.trim();
    final usuarioLogado = Provider.of<UsuarioController>(context, listen: false).usuario;

    if (texto.isNotEmpty && usuarioLogado != null) {
      setState(() {
        mensagens.add(
          Mensagem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            conteudo: texto,
            dataEnvio: 'agora',
            usuario: Usuario.fromDetails(Provider.of<UsuarioController>(context, listen: false).usuario!),
          ),
        );
      });
      _mensagemController.clear();
      _scrollParaFim();

      // Aqui você pode chamar sua API para enviar a mensagem de fato,
      // e depois recarregar as mensagens (ou atualizar o estado conforme o retorno)
    }
  }

  void _scrollParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioLogado = Provider.of<UsuarioController>(context, listen: false).usuario;
    final primaryColor = Colors.pinkAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.evento.titulo}'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : mensagens.isEmpty
                    ? const Center(child: Text('Nenhuma mensagem ainda.'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: mensagens.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final reversedIndex = mensagens.length - 1 - index;
                          final msg = mensagens[reversedIndex];
                          final souEu = msg.usuario.id == usuarioLogado?.id;

                          return Align(
                            alignment: souEu
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Card(
                              color: souEu
                                  ? primaryColor.withOpacity(0.8)
                                  : Colors.grey[300],
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.usuario.nome,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: souEu ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg.conteudo,
                                      style: TextStyle(
                                        color: souEu ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      msg.dataEnvio,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: souEu
                                            ? Colors.white70
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensagemController,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: primaryColor),
                  onPressed: () {
                    enviarMensagem();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
