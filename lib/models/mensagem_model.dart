import 'package:festora/models/usuario_response_model.dart';

class Mensagem {
  final String id;
  final String conteudo;
  final String dataEnvio;
  final Usuario usuario;

  Mensagem({
    required this.id,
    required this.conteudo,
    required this.dataEnvio,
    required this.usuario,
  });

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'],
      conteudo: json['conteudo'],
      dataEnvio: json['dataEnvio'],
      usuario: Usuario.fromJson(json['usuario']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conteudo': conteudo,
      'dataEnvio': dataEnvio,
      'usuario': {
        'id': usuario.id,
        'nome': usuario.nome,
      },
    };
  }
}
