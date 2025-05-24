import 'package:festora/models/usuario_details_model.dart';

class Usuario {
  final String id;
  final String nome;

  Usuario({
    required this.id,
    required this.nome,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
    );
  }

  factory Usuario.fromDetails(UsuarioDetailsModel details) {
    return Usuario(
      id: details.id,
      nome: details.nome,
    );
  }
}
