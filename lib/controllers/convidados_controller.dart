import 'package:festora/models/usuario_response_model.dart';
import 'package:flutter/material.dart';

class ConvidadosController extends ChangeNotifier {
  List<Usuario> _convidados = [];

  List<Usuario> _amigos = [];

  List<Usuario> _participantes = [];

  bool convidadosCarregados = false;

  bool listasCarregadas = false;

  List<Usuario> get convidados => _convidados;

  List<Usuario> get amigos => _amigos;

  List<Usuario> get participantes => _participantes;

  void setConvidados(List<Usuario> convidados) {
    _convidados = convidados;

    convidadosCarregados = true;
    notifyListeners();
  }

  void setListas(List<Usuario> amigos, List<Usuario> participantes) {
    _participantes = participantes;

    final participantesIds = _participantes.map((p) => p.id).toSet();
    final convidadosIds = _convidados.map((c) => c.id).toSet();

    final idsIndisponiveis = {...participantesIds, ...convidadosIds};

    _amigos = amigos.where((a) => !idsIndisponiveis.contains(a.id)).toList();

    listasCarregadas = true;
    notifyListeners();
  }

  void adicionarConvidados(List<String> novosConvidadosIds) {
    List<Usuario> selecionados = [];

    for (var id in novosConvidadosIds) {
      final amigo = _amigos.firstWhere(
        (a) => a.id == id,
      );

      if (amigo.id.isNotEmpty) {
        selecionados.add(amigo);
      }
    }

    // Remove os selecionados da lista de amigos
    _amigos.removeWhere((a) => novosConvidadosIds.contains(a.id));

    // Adiciona à lista de convidados
    _convidados.addAll(selecionados);

    notifyListeners();
  }

  void limparListas() {
    _convidados.clear();
    _amigos.clear();
    _participantes.clear();

    listasCarregadas = false;
    convidadosCarregados = false;
    notifyListeners();
  }

  void excluirConvidadoPorId(String id) {
    int index = _convidados.indexWhere((convidado) => convidado.id == id);

    if (index != -1) {
      // Remove da lista de convidados
      final removido = _convidados.removeAt(index);

      // Adiciona de volta à lista de amigos
      _amigos.add(removido);

      notifyListeners();
    }
  }

  void atualizarAmigosDisponiveis() {
    final participantesIds = _participantes.map((p) => p.id).toSet();
    final convidadosIds = _convidados.map((c) => c.id).toSet();
    final idsIndisponiveis = {...participantesIds, ...convidadosIds};

    _amigos = _amigos.where((a) => !idsIndisponiveis.contains(a.id)).toList();
    notifyListeners();
  }

  void adicionarAmigosDisponiveis(Usuario usuario) {
    if (listasCarregadas) {
      amigos.add(usuario);

      notifyListeners();
    }
  }
}
