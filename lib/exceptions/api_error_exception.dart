import 'package:festora/models/api_error_model.dart';

class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);
}