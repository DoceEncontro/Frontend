import 'package:festora/pages/event/ver_evento/detalhes_evento_page.dart';
import 'package:festora/services/token_service.dart';
import 'package:festora/utils/redirecionar_util.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/services/evento_service.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});
  static const String routeName = '/agenda';

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  Map<DateTime, List<EventoModel>> eventosPorData = {};
  List<EventoModel> eventosSelecionados = [];
  DateTime diaSelecionado = DateTime.now();

  @override
  void initState() {
    TokenService.limparToken();
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    final eventos = await EventoService().listarEventosAtivos();
    final mapa = <DateTime, List<EventoModel>>{};

    print('EVENTOS CARREGADOS:');
    for (var e in eventos) {
      print('${e.titulo} - ${e.data}');
    }
    final formatador = DateFormat('dd/MM/yyyy HH:mm');
    for (var evento in eventos) {
      final data = formatador.parse(evento.data!);
      final dia = DateTime.utc(data.year, data.month, data.day);
      mapa[dia] = [...(mapa[dia] ?? []), evento];
    }

    final diaAtual = DateTime.utc(
      diaSelecionado.year,
      diaSelecionado.month,
      diaSelecionado.day,
    );

    setState(() {
      eventosPorData = mapa;
      eventosSelecionados = mapa[diaAtual] ?? [];
    });
  }

  List<EventoModel> _obterEventosDoDia(DateTime dia) {
    final diaLocal = DateTime.utc(dia.year, dia.month, dia.day); // <- e aqui!
    return eventosPorData[diaLocal] ?? [];
  }

  Widget _buildLegendaItem(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Setinha (mantida funcional)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // Espaço para centralizar o título
            Expanded(
              child: Center(
                child: Text(
                  'Agenda de Eventos',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Espaço invisível para compensar a seta (mesma largura da seta)
            const SizedBox(width: 48),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendaItem(const Color(0xFF04FF00), "Seus eventos"),
                  _buildLegendaItem(
                      const Color(0xFF78003C), "Eventos de amigos"),
                ],
              ),
            ),
          ),
          TableCalendar<EventoModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: diaSelecionado,
            eventLoader: _obterEventosDoDia,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) => isSameDay(day, diaSelecionado),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                diaSelecionado = selectedDay;
                eventosSelecionados = _obterEventosDoDia(selectedDay);
              });
            },
            calendarBuilders:
                CalendarBuilders(markerBuilder: (context, date, eventos) {
              if (eventos.isEmpty) return const SizedBox();

              return Positioned(
                bottom: 2, // distância da parte inferior da célula
                child: Container(
                  width: 10, // largura da bolinha
                  height: 10, // altura da bolinha
                  decoration: BoxDecoration(
                    color: const Color(0xFF04FF00), // cor da bolinha
                    shape: BoxShape.circle, // formato circular
                    border: Border.all(
                      // borda opcional
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      // sombra opcional
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: eventosSelecionados.isEmpty
                ? const Center(child: Text('Nenhum evento neste dia.'))
                : ListView.builder(
                    itemCount: eventosSelecionados.length,
                    itemBuilder: (context, index) {
                      final evento = eventosSelecionados[index];
                      final formatador = DateFormat('dd/MM/yyyy HH:mm');
                      final data = formatador.parse(evento.data!);
                      return ListTile(
                        title: Text(evento.titulo ?? 'Sem título'),
                        subtitle: Text(formatador.format(data)),
                        leading:
                            const Icon(Icons.event_note, color: Colors.pink),
                        onTap: () {
                          final eventoId = evento.id;
                          if (eventoId != null) {
                            Redirecionar().eventoDetails(context, eventoId);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
