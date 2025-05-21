import 'package:festora/controllers/evento_controller.dart';
import 'package:festora/controllers/usuario_controller.dart';
import 'package:festora/pages/funcionalidades/amigos/convites/convite_page.dart';
import 'package:festora/utils/redirecionar_util.dart';
import 'package:festora/utils/rota_anterior_utils.dart';
import 'package:flutter/material.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/models/usuario_details_model.dart' as u;
import 'package:festora/services/evento_service.dart';
import 'package:festora/services/token_service.dart';
import 'package:festora/services/usuario_service.dart';
import 'package:festora/widgets/appBar/gradient_appbar.dart';
import 'package:festora/widgets/containers/animated_gradient_border_container.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:festora/pages/event/ver_evento/detalhes_evento_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onCreatePressed});
  static const String name = 'HomePage';

  @override
  State<HomePage> createState() => HomePageState();
  final VoidCallback? onCreatePressed;
}

class HomePageState extends State<HomePage> {
  Timer? _tokenTimer;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _tokenTimer = Timer.periodic(const Duration(seconds: 300), (timer) {
      TokenService.verificarToken(context);
    });
  }

  @override
  void dispose() {
    _tokenTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    TokenService.verificarToken(context);
  }

  Future<void> desativarEvento(String eventoId) async {
    try {
      await EventoService().desativarEvento(eventoId);

      Provider.of<EventoController>(context, listen: false)
          .excluirEventoPorId(eventoId);
    } catch (e) {}
  }

  // Future<void> _enviarMensagemWhatsApp() async {
  //   final telefone = '5511950497880';
  //   final mensagem = Uri.encodeComponent("Olá, tudo bem?");
  //   final url = Uri.parse("https://wa.me/$telefone?text=$mensagem");

  //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //     throw Exception('Não foi possível abrir o WhatsApp.');
  //   }
  // }

  void redirecionarEvento(String eventoId) {
    final uri = Uri.parse('/detalhes-evento?eventoId=$eventoId');
    GoRouter.of(context).go(uri.toString());
  }

  final List<Map<String, dynamic>> funcoes = [
    {"icon": Icons.add, "label": "Criar Evento"},
    {"icon": Icons.calendar_today, "label": "Agenda"},
    {"icon": Icons.group, "label": "Amigos"},
    {"icon": Icons.mail, "label": "Convites"},
  ];

  @override
  Widget build(BuildContext context) {
    final chas = Provider.of<EventoController>(context).eventos;
    final usuario = Provider.of<UsuarioController>(context).usuario;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),
        appBar: GradientAppBar(usuario!.nome),
        body: RefreshIndicator(
          onRefresh: _carregarDados,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              children: [
                if (chas.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: chas.length,
                      itemBuilder: (context, index) {
                        final evento = chas[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 250,
                            child: AnimatedGradientBorderContainer(
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(13),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(13),
                                  splashColor: Colors.transparent,
                                  highlightColor:
                                      const Color.fromARGB(255, 233, 245, 255),
                                  onTap: () {
                                    RotaAnteriorUtils.setRota(context);
                                    final eventoId = evento.id;
                                    if (eventoId != null) {
                                      Redirecionar()
                                          .eventoDetails(context, eventoId);
                                    }
                                  },
                                  onLongPress: () {
                                    setState(() {});
                                    _mostrarOpcoesEvento(context, evento);
                                  },
                                  onHighlightChanged: (isHighlighted) {},
                                  splashFactory: InkSplash.splashFactory,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                evento.titulo ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                evento.descricao ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            _formatarData(evento.data),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (chas.isNotEmpty) const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.black45),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                    children: funcoes.map((item) {
                      return GestureDetector(
                        onTap: () {
                          if (item['label'] == 'Criar Evento') {
                            widget.onCreatePressed?.call();
                          } else if (item['label'] == 'Agenda') {
                            GoRouter.of(context).pushNamed('agenda');
                          } else if (item['label'] == 'Amigos') {
                            GoRouter.of(context).pushNamed('amigos');
                          } else if (item['label'] == 'Convites') {
                            showDialog(
                              context: context,
                              builder: (context) => const ConvitesModal(),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item['icon'], size: 30, color: Colors.black),
                              const SizedBox(height: 8),
                              Text(
                                item['label'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatarData(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  void _mostrarOpcoesEvento(BuildContext context, EventoModel evento) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Editar Evento'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () async {
                    final ehAutor = await EventoService()
                        .verificarSeUsuarioEhAutor(evento.id!);
                    if (ehAutor) {
                      final result = await context
                          .pushNamed<String>('criar-evento', extra: evento);
                      if (result == 'evento_editado') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Evento atualizado com sucesso!')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Você não tem permissão para editar este evento.')),
                      );
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Excluir Evento'),
                onTap: () async {
                  Navigator.of(context).pop();

                  Future<bool> _confirmarExclusao(BuildContext context) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: const Text(
                                  'Você tem certeza que deseja excluir este evento?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => {
                                    desativarEvento(evento.id!),
                                    Navigator.of(context).pop(true),
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                  }

                  final ehAutor = await EventoService()
                      .verificarSeUsuarioEhAutor(evento.id!);
                  if (ehAutor) {
                    bool confirmado = await _confirmarExclusao(context);
                    if (confirmado) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Evento excluído com sucesso!'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Você não tem permissão para excluir este evento.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
