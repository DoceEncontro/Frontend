import 'package:festora/models/evento_model.dart';
import 'package:flutter/material.dart';

class EventoController extends ChangeNotifier {
  List<EventoModel> _eventos = [];

  List<EventoModel> get eventos => _eventos;

  List<EventoModel> _eventosAutor = [];

  List<EventoModel> get eventosAutor => _eventosAutor;

  List<EventoModel> _eventosPassados = [];

  List<EventoModel> get eventosPassados => _eventosPassados;

  bool autorCarregado = false;

  bool passadosCarregado = false;

  void setEventos(List<EventoModel> novosEventos) {
    _eventos = novosEventos;
    notifyListeners();
  }

  void setEventosAutor(List<EventoModel> eventosAutor) {
    _eventosAutor = eventosAutor;

    autorCarregado = true;
    notifyListeners();
  }

  void setEventosPassados(List<EventoModel> eventosPassados) {
    _eventosPassados = eventosPassados;

    passadosCarregado = true;
    notifyListeners();
  }

  void adicionarEvento(EventoModel evento) {
    _eventos.add(evento);
    notifyListeners();
  }

  void limparEventos() {
    _eventos.clear();
    _eventosAutor.clear();
    _eventosPassados.clear();
    notifyListeners();
  }

  void editarEventoPorId(EventoModel novoEvento) {
    int index = _eventos.indexWhere((evento) => evento.id == novoEvento.id);
    int indexAutor =
        _eventosAutor.indexWhere((evento) => evento.id == novoEvento.id);

    int indexPassados =
        _eventosPassados.indexWhere((evento) => evento.id == novoEvento.id);

    if (index != -1) {
      _eventos[index] = novoEvento;
    }

    if (indexAutor != -1) {
      _eventosAutor[indexAutor] = novoEvento;
    }

    if (indexPassados != -1) {
      _eventosPassados[indexPassados] = novoEvento;
    }
    notifyListeners();
  }

  void excluirEventoPorId(String id) {
    _eventos.removeWhere((evento) => evento.id == id);
    _eventosAutor.removeWhere((evento) => evento.id == id);
    _eventosPassados.removeWhere((evento) => evento.id == id);

    notifyListeners();
  }
}
