import 'dart:convert';
import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/utils/rota_anterior_utils.dart';
import 'package:flutter/material.dart';
import 'package:festora/services/evento_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DetalhesEventoPage extends StatefulWidget {
  final String eventoId;

  const DetalhesEventoPage({super.key, required this.eventoId});

  static const String routeName = 'detalhes-evento';
  static const String routePath = '/detalhes-evento';

  @override
  State<DetalhesEventoPage> createState() => _DetalhesEventoPageState();
}

class _DetalhesEventoPageState extends State<DetalhesEventoPage> {
  late EventoDetails evento;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    carregarEvento();
  }

  Future<void> carregarEvento() async {
    try {
      final (ok, eventoCarregado) =
          await EventoService().buscarEvento(widget.eventoId);
      if (!mounted) return;
      setState(() {
        evento = eventoCarregado;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return const Scaffold(
        body: Center(child: Text('Erro ao carregar evento.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            RotaAnteriorUtils.redirecionar(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                evento.titulo,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                evento.descricao,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.people,
                                      color: Color.fromARGB(255, 192, 56, 138)),
                                  tooltip: 'Participantes',
                                  onPressed: () {
                                    // Para ser Implementado
                                  },
                                ),
                                const Text(
                                  '0 participantes',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16), // espaço entre os ícones
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.person_add_alt_1,
                                      color: Colors.purple),
                                  tooltip: 'Convidar',
                                  onPressed: () {
                                    context.pushNamed(
                                      'convidados',
                                      extra: evento,
                                    );
                                  },
                                ),
                                const Text(
                                  '0 convidados',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoItem('Tipo', evento.tipo),
                    _buildInfoItem('Data e Hora', _formatarData(evento.data)),
                    _buildInfoItem('Local', evento.endereco.local),
                    _buildInfoItem(
                      'Endereço',
                      '${evento.endereco.rua}, ${evento.endereco.numero} - ${evento.endereco.cidade} - ${evento.endereco.estado}',
                    ),
                    const SizedBox(height: 24),
                    if (evento.isAutor)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            label: const Text('Editar',
                                style: TextStyle(color: Colors.blue)),
                            onPressed: () async {
                              EventoModel eventoModel =
                                  EventoModel.fromDetails(evento);
                              final result = await context.pushNamed<String>(
                                'criar-evento',
                                extra: eventoModel,
                              );
                              if (context.mounted &&
                                  result == 'evento_editado') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Evento atualizado com sucesso!'),
                                  ),
                                );
                                setState(() {
                                  isLoading = true;
                                });
                                await carregarEvento(); // recarrega os dados do evento atualizado
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Excluir Evento'),
                                      content: const Text(
                                          'Tem certeza que deseja excluir este evento?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (confirm) {
                                try {
                                  await EventoService()
                                      .desativarEvento(evento.id!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Evento excluído com sucesso.')),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Erro ao excluir evento.')),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                _buildIconTile(Icons.chat, 'Chat', iconColor: Colors.blue,
                    onTap: () {
                  // TODO: implementar
                }),
                _buildIconTile(Icons.list, 'Presentes',
                    iconColor: const Color.fromARGB(255, 0, 202, 252),
                    onTap: () {
                  GoRouter.of(context)
                      .pushNamed('presente-evento', extra: evento);
                }),
                _buildIconTile(Icons.people, 'Participantes',
                    iconColor: const Color.fromARGB(255, 192, 56, 138),
                    onTap: () {
                  // TODO: implementar
                }),
                _buildIconTile(Icons.group_add, 'Convidados',
                    iconColor: Colors.purple, onTap: () {
                  context.pushNamed(
                    'convidados',
                    extra: evento,
                  );
                }),
                _buildIconTile(Icons.map, 'Localização',
                    iconColor: const Color.fromARGB(255, 56, 192, 61),
                    onTap: () {
                  // TODO: implementar
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconTile(IconData icon, String label,
      {Color iconColor = Colors.black, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
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
}
