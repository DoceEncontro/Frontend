import 'package:festora/models/evento_details_model.dart';
import 'package:flutter/material.dart';
import 'package:festora/models/evento_model.dart';
import 'package:festora/services/amizade_service.dart';
import 'package:festora/services/convite_service.dart';

class ConvidarAmigosPage extends StatefulWidget {
  final EventoDetails evento;
  const ConvidarAmigosPage({super.key, required this.evento});
  static const String routeName = 'convidar-amigos';

  @override
  State<ConvidarAmigosPage> createState() => _ConvidarAmigosPageState();
}

class _ConvidarAmigosPageState extends State<ConvidarAmigosPage> {
  List<Map<String, dynamic>> amigos = [];
  List<String> selecionados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarAmigos();
  }

  Future<void> carregarAmigos() async {
    // try {
    //   final lista = await AmizadeService().listarAceitos();
    //   setState(() {
    //     amigos = lista;
    //     carregando = false;
    //   });
    // } catch (_) {
    //   setState(() => carregando = false);
    // }
  }

  Future<void> enviarConvites() async {
    try {
      await ConviteService().enviarConvites(widget.evento.id!, selecionados);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convites enviados com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar convites.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convidar Amigos')),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: amigos.length,
                    itemBuilder: (context, index) {
                      final amigo = amigos[index];
                      final id = amigo['amigo']['id'];
                      final nome = amigo['amigo']['nome'];
                      return CheckboxListTile(
                        title: Text(nome),
                        value: selecionados.contains(id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selecionados.add(id);
                            } else {
                              selecionados.remove(id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: selecionados.isEmpty ? null : enviarConvites,
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar Convites'),
                ),
              ],
            ),
    );
  }
}