import 'package:festora/models/criar_evento_erro_model.dart';

class EventoFormException implements Exception {
  final EventoErroModel errors;

  EventoFormException(this.errors);
}