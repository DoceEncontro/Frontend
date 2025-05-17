class NotificacaoModel {
  final String id;
  final String titulo;
  final String corpo;
  final String data;
  final String icone;

  NotificacaoModel({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.data,
    required this.icone,
  });

  factory NotificacaoModel.fromJson(Map<String, dynamic> json) {
    return NotificacaoModel(
      id: json['id'],
      titulo: json['titulo'],
      corpo: json['corpo'],
      data: json['data'],
      icone: json['icone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'corpo': corpo,
      'data': data,
      'icone': icone,
    };
  }
}
