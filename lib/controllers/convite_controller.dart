import 'package:festora/models/convite_model.dart';
import 'package:flutter/material.dart';

class ConviteController extends ChangeNotifier {
  List<ConviteModel> _convites = [];

  bool isCarregado = false;

  List<ConviteModel> get convites => _convites;

  void setconvites(List<ConviteModel> convites) {
    _convites = convites;

    isCarregado = true;

    notifyListeners();
  }

  void removerConvitePorId(String conviteId) {
    _convites.removeWhere((convite) => convite.id == conviteId);
    notifyListeners();
  }

  void limparConvites() {
    _convites.clear();

    isCarregado = false;

    notifyListeners();
  }
}
