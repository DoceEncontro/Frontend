class NotificacaoModel {
  final String id;
  final String titulo;
  final String corpo;
  final String data;

  NotificacaoModel({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.data,
  });

  factory NotificacaoModel.fromJson(Map<String, dynamic> json) {
    return NotificacaoModel(
      id: json['id'],
      titulo: json['titulo'],
      corpo: json['corpo'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'corpo': corpo,
      'data': data,
    };
  }
}
