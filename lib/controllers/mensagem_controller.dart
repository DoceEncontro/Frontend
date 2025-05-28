import 'dart:convert';

import 'package:festora/models/mensagem_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

class MensagemController extends ChangeNotifier {
  List<Mensagem> _mensagens = [];

  StompClient? _client;

  final backUrl = dotenv.env['BACK_URL'];

  bool isCarregado = false;

  List<Mensagem> get mensagens => _mensagens;

  void setMensagens(List<Mensagem> mensagens, String chatId) {
    _mensagens = mensagens;
    isCarregado = true;
    conectar(chatId);
    notifyListeners();
  }

  void conectar(String chatId) {
    if (_client != null) return;

    _client = StompClient(
      config: StompConfig.SockJS(
        url: '$backUrl/ws',
        onConnect: (frame) {
          _client!.subscribe(
            destination: '/topic/chat/$chatId',
            callback: (frame) {
              if (frame.body != null) {
                final nova = Mensagem.fromJson(jsonDecode(frame.body!));
                adicionarMensagem(nova);
              }
            },
          );
        },
        onWebSocketError: (err) => print("Erro: $err"),
      ),
    );

    _client!.activate();
  }


  void adicionarMensagem(Mensagem mensagem) {
    _mensagens.add(mensagem);
    notifyListeners();
  }

  void desconectar() {
    _client?.deactivate();
    _client = null;
  }

  void limparMensagens() {
    _mensagens.clear();
    isCarregado = false;
    desconectar();
    notifyListeners();
  }
}
