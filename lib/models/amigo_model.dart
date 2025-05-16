import 'package:festora/models/usuario_response_model.dart';

class Amigo {
  final String amizadeId;
  final Usuario amigo;
  final String status;

  Amigo({
    required this.amizadeId,
    required this.amigo,
    required this.status,
  });

  factory Amigo.fromJson(Map<String, dynamic> json) {
    return Amigo(
      amizadeId: json['amizadeId'],
      amigo: Usuario.fromJson(json['amigo']),
      status: json['status'],
    );
  }
}
