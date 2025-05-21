class ConviteModel {
  final String id;
  final String eventoId;
  final String organizador;
  final String titulo;
  final String descricao;

  ConviteModel({
    required this.id,
    required this.eventoId,
    required this.organizador,
    required this.titulo,
    required this.descricao,
  });

  factory ConviteModel.fromJson(Map<String, dynamic> json) {
    return ConviteModel(
      id: json['id'],
      eventoId: json['eventoId'],
      organizador: json['organizador'],
      titulo: json['titulo'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventoId': eventoId,
      'organizador': organizador,
      'titulo': titulo,
      'descricao': descricao,
    };
  }
}
