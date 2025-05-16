import 'package:festora/models/usuario_details_model.dart';
import 'package:flutter/material.dart';

class UsuarioController extends ChangeNotifier {
  UsuarioDetailsModel? _usuario;

  UsuarioDetailsModel? get usuario => _usuario;

  bool isCarregado = false;

  void setUsuario(UsuarioDetailsModel usuario) {
    _usuario = usuario;

    isCarregado = true;

    notifyListeners();
  }

  void limparUser() {
    _usuario = null;

    isCarregado = false;

    notifyListeners();
  }
}
