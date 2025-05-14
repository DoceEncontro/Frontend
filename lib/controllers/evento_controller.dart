import 'package:festora/models/evento_model.dart';
import 'package:flutter/material.dart';

class EventoController extends ChangeNotifier {
  List<EventoModel> _eventos = [];

  List<EventoModel> get eventos => _eventos;

  void setEventos(List<EventoModel> novosEventos) {
    _eventos = novosEventos;
    notifyListeners();
  }

  void adicionarEvento(EventoModel evento) {
    _eventos.add(evento);
    notifyListeners();
  }

  void limparEventos() {
    _eventos.clear();
    notifyListeners();
  }

  void editarEventoPorId(EventoModel novoEvento) {
    int index = _eventos.indexWhere((evento) => evento.id == novoEvento.id);

    // Se o evento for encontrado, substitui
    if (index != -1) {
      _eventos[index] = novoEvento;
      notifyListeners();
    }
  }

  void excluirEventoPorId(String id) {
    int index = _eventos.indexWhere((evento) => evento.id == id);

    if (index != -1) {
      _eventos.removeAt(index);
      notifyListeners();
    }
  }
}
