import 'package:festora/models/endereco_model.dart';
import 'package:festora/models/presente_model.dart';
import 'package:festora/models/usuario_response_model.dart';

class EventoDetails {
  final String id;
  final String titulo;
  final String descricao;
  final String tipo;
  final String data;
  final bool ativo;
  final EnderecoModel endereco;
  final Usuario organizador;
  final String chatId;
  final bool isAutor;

  EventoDetails({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.data,
    required this.ativo,
    required this.endereco,
    required this.organizador,
    required this.isAutor,
    required this.chatId,
  });

  factory EventoDetails.fromJson(Map<String, dynamic> json) {
    return EventoDetails(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      tipo: json['tipo'],
      data: json['data'],
      ativo: json['ativo'],
      endereco: EnderecoModel.fromJson(json['endereco']),
      organizador: Usuario.fromJson(json['organizador']),
      isAutor: json['autor'],
      chatId: json['chatId'],
    );
  }
}