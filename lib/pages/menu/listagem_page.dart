import 'package:festora/controllers/evento_controller.dart';
import 'package:festora/utils/redirecionar_util.dart';
import 'package:festora/utils/rota_anterior_utils.dart';
import 'package:flutter/material.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/services/evento_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListagemPage extends StatefulWidget {
  static const String name = 'listagem';

  const ListagemPage({super.key});

  @override
  State<ListagemPage> createState() => ListagemPageState();
}

class ListagemPageState extends State<ListagemPage> {
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
  }

  String _formatarData(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventos = Provider.of<EventoController>(context).eventos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(ListagemPage.name);
          },
        ),
      ),
      backgroundColor: const Color(0xFFF3F3F3),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : eventos.isEmpty
              ? const Center(child: Text('Nenhum evento encontrado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    final evento = eventos[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        RotaAnteriorUtils.setRota(context);
                        final eventoId = evento.id;
                        if (eventoId != null) {
                          Redirecionar().eventoDetails(context, eventoId);
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                evento.titulo ?? 'Sem título',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                evento.descricao ?? 'Sem descrição',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Data: ${_formatarData(evento.data)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    label: const Text('Editar'),
                                    onPressed: () async {
                                      final result =
                                          await context.pushNamed<String>(
                                        'criar-evento',
                                        extra: evento,
                                      );
                                      if (result == 'evento_editado') {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Evento atualizado com sucesso!')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    label: const Text('Excluir'),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Excluir Evento'),
                                              content: const Text(
                                                  'Tem certeza que deseja excluir este evento?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  child: const Text('Excluir'),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;

                                      if (confirm) {
                                        final sucesso = await EventoService()
                                            .desativarEvento(evento.id!);
                                        if (sucesso) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Evento excluído com sucesso.'),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Erro ao excluir evento.'),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
    );
  }
}
