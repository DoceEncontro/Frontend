import 'package:festora/models/usuario_details_model.dart';
import 'package:flutter/material.dart';

class UsuarioController extends ChangeNotifier {
  late UsuarioDetailsModel _usuario;

  UsuarioDetailsModel get usuario => _usuario;

  void setUsuario(UsuarioDetailsModel usuario) {
    _usuario = usuario;
    notifyListeners();
  }
}
