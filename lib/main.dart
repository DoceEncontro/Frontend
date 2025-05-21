import 'package:festora/controllers/amigos_controller.dart';
import 'package:festora/controllers/convidados_controller.dart';
import 'package:festora/controllers/convite_controller.dart';
import 'package:festora/controllers/evento_controller.dart';
import 'package:festora/controllers/notificacao_controller.dart';
import 'package:festora/controllers/participantes_controller.dart';
import 'package:festora/controllers/presente_controller.dart';
import 'package:festora/controllers/usuario_controller.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/pages/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventoController()),
        ChangeNotifierProvider(create: (_) => UsuarioController()),
        ChangeNotifierProvider(create: (_) => PresenteController()),
        ChangeNotifierProvider(create: (_) => ParticipantesController()),
        ChangeNotifierProvider(create: (_) => ConvidadosController()),
        ChangeNotifierProvider(create: (_) => AmigosController()),
        ChangeNotifierProvider(create: (_) => NotificacaoController()),
        ChangeNotifierProvider(create: (_) => ConviteController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Festora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
