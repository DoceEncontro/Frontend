import 'package:flutter/material.dart';

class IconeHelper {
  static IconData iconeFromString(String icone) {
    switch (icone) {
      case 'mail':
        return Icons.mail;
      case 'event':
        return Icons.event;
      case 'message':
        return Icons.message;
      case 'check_circle':
        return Icons.check_circle;
      case 'notifications':
        return Icons.notifications;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'error':
        return Icons.error;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'person_add':
        return Icons.person_add_alt_1;
      default:
        return Icons.notifications; // ícone padrão
    }
  }
}
