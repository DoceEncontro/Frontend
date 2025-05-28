import 'dart:convert';

import 'package:festora/controllers/mensagem_controller.dart';
import 'package:festora/controllers/usuario_controller.dart';
import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/mensagem_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  bool carregando = true;

  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _carregarMensagens() async {
    setState(() => carregando = true);

    if (!Provider.of<MensagemController>(context, listen: false).isCarregado) {
      try {
        final lista = await _chatService.obterMensagens(widget.evento.chatId);

        Provider.of<MensagemController>(context, listen: false)
            .setMensagens(lista, widget.evento.chatId);

        _scrollParaFim();
      } catch (e) {
        debugPrint('Erro ao carregar mensagens: $e');
      }
    }
    setState(() => carregando = false);
  }

  void enviarMensagem() async {
    final texto = _mensagemController.text.trim();
    final usuarioLogado =
        Provider.of<UsuarioController>(context, listen: false).usuario;

    if (texto.isNotEmpty && usuarioLogado != null) {
      _mensagemController.clear();

      try {
        await ChatService().enviarMensagem(texto, widget.evento.chatId);

        _scrollParaFim();
      } catch (e) {
        print('Erro ao enviar mensagem: $e');
      }
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
    final usuarioLogado =
        Provider.of<UsuarioController>(context, listen: false).usuario;
    final mensagens =
        Provider.of<MensagemController>(context).mensagens;

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
                                        color:
                                            souEu ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg.conteudo,
                                      style: TextStyle(
                                        color:
                                            souEu ? Colors.white : Colors.black,
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
