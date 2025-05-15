import 'package:festora/models/usuario_response_model.dart';
import 'package:flutter/material.dart';

class ParticipantesController extends ChangeNotifier {
  List<Usuario> _participantes = [];

  bool isCarregado = false;

  List<Usuario> get participantes => _participantes;

  void setParticipantes(List<Usuario> novosParticipantes) {
    _participantes = novosParticipantes;
    isCarregado = true;
    notifyListeners();
  }

  void adicionarParticipante(Usuario participante) {
    _participantes.add(participante);
    notifyListeners();
  }

  void limparParticipantes() {
    _participantes.clear();
    isCarregado = false;
    notifyListeners();
  }

  void excluirParticipantePorId(String id) {
    int index = _participantes.indexWhere((participante) => participante.id == id);

    if (index != -1) {
      _participantes.removeAt(index);
      notifyListeners();
    }
  }
}