import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/pages/convite/convite.dart';
import 'package:festora/pages/event/presente_evento.dart';
import 'package:festora/pages/funcionalidades/amigos/adicionar_amigo_page.dart';
import 'package:festora/pages/funcionalidades/amigos/amigos_page.dart';
import 'package:festora/pages/funcionalidades/amigos/convidar_amigos_page.dart';
import 'package:festora/pages/funcionalidades/amigos/convites/convite_page.dart';
import 'package:festora/pages/funcionalidades/calendario_page.dart';
import 'package:festora/pages/funcionalidades/convidados_page.dart';
import 'package:festora/pages/funcionalidades/participantes_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../help/help_page.dart';
import '../login/login_page.dart';
import '../login/register_page.dart';
import '../event/criar_editar/criar_editar_evento__page.dart';
import '../event/ver_evento/detalhes_evento_page.dart';
import '../menu/home_section_page.dart';

abstract class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Rotas principais
      GoRoute(
        path: '/login',
        name: LoginPage.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/help',
        name: HelpPage.name,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: '/register',
        name: RegisterPage.name,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/menu',
        name: HomeSectionPage.name,
        builder: (context, state) => const HomeSectionPage(),
      ),

      GoRoute(
        path: '/criar-evento',
        name: 'criar-evento',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is EventoModel) {
            return CriarEventoPage(evento: extra);
          } else if (extra is String) {
            return CriarEventoPage(tipoEvento: extra);
          } else {
            return const Scaffold(
              body: Center(
                  child: Text('Parâmetro inválido para criação de evento')),
            );
          }
        },
      ),

      // 📄 DETALHES DO EVENTO (ShellRoute)
      GoRoute(
        path: '/detalhes-evento',
        name: DetalhesEventoPage.routeName, // 'detalhes-evento'
        builder: (context, state) {
          final eventoId = state.uri.queryParameters['eventoId'];

          // Verifique se o eventoId está presente
          if (eventoId != null && eventoId.isNotEmpty) {
            return DetalhesEventoPage(eventoId: eventoId); // Passando eventoId
          } else {
            return const Scaffold(
              body: Center(child: Text('Evento não encontrado.')),
            );
          }
        },
        routes: [
          // Rota de Convidados
          GoRoute(
            path: '/detalhes-evento/convidados',
            name: ConvidadosPage.routeName,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is EventoDetails) {
                return ConvidadosPage(evento: extra);
              } else {
                return const Scaffold(
                  body: Center(child: Text('Evento não encontrado.')),
                );
              }
            },
          ),
          // Rota de Participantes
          GoRoute(
            path: '/detalhes-evento/participantes',
            name: ParticipantesPage.routeName,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is EventoDetails) {
                return ParticipantesPage(evento: extra);
              } else {
                return const Scaffold(
                  body: Center(child: Text('Evento não encontrado.')),
                );
              }
            },
          ),
          // Rota de Presentes
          GoRoute(
            path: '/detalhes-evento/presente',
            name: 'presente-evento',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is EventoDetails) {
                return PresenteEventoPage(evento: extra);
              } else {
                return const Scaffold(
                  body: Center(child: Text('Evento inválido.')),
                );
              }
            },
          ),
        ],
      ),

      GoRoute(
        path: '/agenda',
        name: 'agenda',
        builder: (context, state) => const AgendaPage(),
      ),
      GoRoute(
        path: '/amigos',
        name: AmigosPage.routeName,
        builder: (context, state) => const AmigosPage(),
      ),
      GoRoute(
        path: '/convite',
        name: ConviteLinkPage.routeName,
        builder: (context, state) => const ConviteLinkPage(),
      ),
    ],
  );
}
