import 'package:festora/controllers/evento_controller.dart';
import 'package:festora/exceptions/EventoFormException.dart';
import 'package:festora/models/criar_evento_erro_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/services/evento_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:festora/widgets/containers/animated_gradient_border_container.dart';
import 'package:provider/provider.dart';

class CriarEventoPage extends StatefulWidget {
  final String? tipoEvento;
  final EventoModel? evento;

  const CriarEventoPage({super.key, this.tipoEvento, this.evento});

  static const String routeName = '/criar-evento';

  @override
  State<CriarEventoPage> createState() => _CriarEventoPageState();
}

class _CriarEventoPageState extends State<CriarEventoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  final TextEditingController localController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController ruaController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  late String tipoSelecionado;

  DateTime? selectedDate;

  EventoErroModel _eventoErroModel = EventoErroModel();

  @override
  void initState() {
    super.initState();

    tipoSelecionado = widget.evento?.tipo ?? widget.tipoEvento ?? '';

    if (widget.evento != null) {
      tituloController.text = widget.evento!.titulo ?? '';
      descricaoController.text = widget.evento!.descricao ?? '';
      localController.text = widget.evento!.local ?? '';
      estadoController.text = widget.evento!.estado ?? '';
      cidadeController.text = widget.evento!.cidade ?? '';
      ruaController.text = widget.evento!.rua ?? '';
      numeroController.text = widget.evento!.numero?.toString() ?? '';

      if (widget.evento?.data != null && widget.evento!.data!.isNotEmpty) {
        try {
          selectedDate = DateTime.tryParse(widget.evento!.data!);
          selectedDate ??=
              DateFormat('dd/MM/yyyy HH:mm').parse(widget.evento!.data!);

          if (selectedDate != null) {
            dataController.text =
                DateFormat('dd/MM/yyyy HH:mm').format(selectedDate!);
          }
        } catch (_) {
          selectedDate = null;
          dataController.text = '';
        }
      }
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    dataController.dispose();
    localController.dispose();
    estadoController.dispose();
    cidadeController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evento != null
            ? "Editar Evento"
            : "Criar ${widget.tipoEvento}"),
        flexibleSpace: AnimatedGradientAppBarBackground(),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    tituloController,
                    'Título',
                    minLen: 10,
                    erroTexto: _eventoErroModel.titulo,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    descricaoController,
                    'Descrição',
                    minLen: 10,
                    maxLines: 3,
                    erroTexto: _eventoErroModel.descricao,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    initialValue: widget.evento?.tipo ?? widget.tipoEvento,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Evento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: dataController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                      errorText: _eventoErroModel.data,
                    ),
                    onTap: _selecionarData,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    localController,
                    'Local',
                    erroTexto: _eventoErroModel.local,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          estadoController,
                          'Estado',
                          erroTexto: _eventoErroModel.estado,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildTextField(
                          cidadeController,
                          'Cidade',
                          erroTexto: _eventoErroModel.cidade,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ruaController,
                          'Rua',
                          erroTexto: _eventoErroModel.rua,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: numeroController,
                          decoration: InputDecoration(
                            labelText: 'Número',
                            border: const OutlineInputBorder(),
                            errorText: _eventoErroModel.numero,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  AnimatedGradientBorderContainer(
                    child: ElevatedButton(
                      onPressed: _salvarEvento,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.evento != null
                            ? "Atualizar Informações"
                            : "Salvar",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int minLen = 0,
    int maxLines = 1,
    String? erroTexto,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: erroTexto,
      ),
    );
  }

  Future<void> _selecionarData() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        final combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          selectedDate = combinedDateTime;
          dataController.text =
              DateFormat('dd/MM/yyyy HH:mm').format(combinedDateTime);
        });
      }
    }
  }

  Future<void> _salvarEvento() async {
    if (_formKey.currentState!.validate()) {
      final evento = EventoModel(
        id: widget.evento?.id,
        titulo: tituloController.text,
        descricao: descricaoController.text,
        tipo: tipoSelecionado,
        data: selectedDate?.toIso8601String() ?? '',
        local: localController.text,
        estado: estadoController.text,
        cidade: cidadeController.text,
        rua: ruaController.text,
        numero: int.tryParse(numeroController.text) ?? 0,
      );

      try {
        EventoModel response;
        if (widget.evento != null) {
          response = await EventoService().editarEvento(evento);
          Provider.of<EventoController>(context, listen: false)
              .editarEventoPorId(response);
        } else {
          response = await EventoService().criarEvento(evento);
          Provider.of<EventoController>(context, listen: false)
              .adicionarEvento(response);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.evento != null
                  ? 'Evento atualizado com sucesso!'
                  : 'Evento criado com sucesso!')),
        );
        context.pop(widget.evento != null ? 'evento_editado' : 'evento_criado');
      } on EventoFormException catch (e) {
        setState(() {
          _eventoErroModel = e.errors; // <-- Aqui pega os erros por campo
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar evento')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro inesperado ao salvar evento')),
        );
      }
    }
  }
}

class AnimatedGradientAppBarBackground extends StatefulWidget {
  const AnimatedGradientAppBarBackground({super.key});

  @override
  State<AnimatedGradientAppBarBackground> createState() =>
      _AnimatedGradientAppBarBackgroundState();
}

class _AnimatedGradientAppBarBackgroundState
    extends State<AnimatedGradientAppBarBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color.fromRGBO(190, 237, 245, 1),
      end: const Color.fromRGBO(240, 203, 218, 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value!,
                _colorAnimation.value!.withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}
