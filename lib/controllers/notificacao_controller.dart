import 'package:festora/models/notificacao_model.dart';
import 'package:flutter/material.dart';

class NotificacaoController extends ChangeNotifier {

  List<NotificacaoModel> _notificacoes = [];

  bool isCarregado = false;

  List<NotificacaoModel> get notificacoes => _notificacoes;

  void setNotificacoes(List<NotificacaoModel> notificacoes) {
    _notificacoes = notificacoes;

    isCarregado = true;

    notifyListeners();
  }

  void limparNotificacoes() {
    _notificacoes.clear();

    isCarregado = false;

    notifyListeners();
  }

}