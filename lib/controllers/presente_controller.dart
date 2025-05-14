import 'package:festora/models/presente_model.dart';
import 'package:flutter/material.dart';

class PresenteController extends ChangeNotifier {
  List<PresenteModel> _presentes = [];

  bool isCarregado = false;

  List<PresenteModel> get presentes => _presentes;

  void setPresentes(List<PresenteModel> novosPresentes) {
    _presentes = novosPresentes;
    isCarregado = true;
    notifyListeners();
  }

  void adicionarPresente(PresenteModel presente) {
    _presentes.add(presente);
    notifyListeners();
  }

  void limparPresentes() {
    _presentes.clear();
    isCarregado = false;
    notifyListeners();
  }

  void editarPresentePorId(PresenteModel novoPresente) {
    int index = _presentes.indexWhere((presente) => presente.id == novoPresente.id);

    // Se o presente for encontrado, substitui
    if (index != -1) {
      _presentes[index] = novoPresente;
      notifyListeners();
    }
  }

  void excluirPresentePorId(String id) {
    int index = _presentes.indexWhere((presente) => presente.id == id);

    if (index != -1) {
      _presentes.removeAt(index);
      notifyListeners();
    }
  }
}
