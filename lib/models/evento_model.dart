import 'package:festora/models/evento_details_model.dart';

class EventoModel {
  final String? id; // <<< Adicionado
  final String titulo;
  final String descricao;
  final String tipo;
  final String data;
  final String local;
  final String estado;
  final String cidade;
  final String rua;
  final int numero;

  final bool? isAutor;

  EventoModel({
    this.id, // <<< Adicionado
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.data,
    required this.local,
    required this.estado,
    required this.cidade,
    required this.rua,
    required this.numero,
    this.isAutor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id, // <<< Adicionado
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo,
      'data': data,
      'local': local,
      'estado': estado,
      'cidade': cidade,
      'rua': rua,
      'numero': numero,
    };
  }

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    final endereco = json['endereco'];

    return EventoModel(
      id: json['id'], // <<< Adicionado
      titulo: json['titulo'],
      descricao: json['descricao'],
      tipo: json['tipo'],
      data: json['data'],
      local: endereco['local'],
      estado: endereco['estado'],
      cidade: endereco['cidade'],
      rua: endereco['rua'],
      numero: endereco['numero'],
      isAutor: json['autor']
    );
  }

  static EventoModel fromDetails(EventoDetails details) {
    return EventoModel(
      id: details.id,
      titulo: details.titulo,
      descricao: details.descricao,
      tipo: details.tipo,
      data: details.data,
      local: details.endereco.local,
      estado: details.endereco.estado,
      cidade: details.endereco.cidade,
      rua: details.endereco.rua,
      numero: details.endereco.numero,
    );
  }
}
