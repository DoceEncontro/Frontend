import 'package:festora/models/amigo_model.dart';
import 'package:flutter/material.dart';

class AmigosController extends ChangeNotifier {
  List<Amigo> _amigos = [];

  List<Amigo> _pendentes = [];

  List<Amigo> _recebidos = [];

  bool amgCarregados = false;

  bool pendCarregados = false;

  bool recebCarregados = false;

  List<Amigo> get amigos => _amigos;

  List<Amigo> get pendentes => _pendentes;

  List<Amigo> get recebidos => _recebidos;

  void setAmigos(List<Amigo> amigos) {
    _amigos = amigos;

    amgCarregados = true;
    notifyListeners();
  }

  void setPendentes(List<Amigo> pendentes) {
    _pendentes = pendentes;

    pendCarregados = true;
    notifyListeners();
  }

  void setRecebidos(List<Amigo> recebidos) {
    _recebidos = recebidos;

    recebCarregados = true;
    notifyListeners();
  }

  void aceitarAmigo(String amizadeId) {
    final amigoAceito = _recebidos.firstWhere(
      (amizade) => amizade.amizadeId == amizadeId,
    );

    _recebidos.removeWhere((amizade) => amizade.amizadeId == amizadeId);
    _amigos.add(amigoAceito);
    notifyListeners();
  }

  void removerAmizade(String amizadeId) {
    _recebidos.removeWhere((amizade) => amizade.amizadeId == amizadeId);
    _amigos.removeWhere((amizade) => amizade.amizadeId == amizadeId);
    _pendentes.removeWhere((amizade) => amizade.amizadeId == amizadeId);

    notifyListeners();
  }

  void enviarPedido(Amigo amigo) {
    _pendentes.add(amigo);

    notifyListeners();
  }

  void limparListas() {
    _recebidos = [];
    _pendentes = [];
    _amigos = [];

    amgCarregados = false;
    pendCarregados = false;
    recebCarregados = false;

    notifyListeners();
  }
}
