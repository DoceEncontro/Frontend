import 'package:festora/controllers/usuario_controller.dart';
import 'package:festora/models/usuario_details_model.dart';
import 'package:flutter/material.dart';
import 'package:festora/services/usuario_service.dart';
import 'package:provider/provider.dart';

class PerfilPage extends StatefulWidget {
  static const String name = 'perfil';

  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    setState(() {
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
      final _usuario = Provider.of<UsuarioController>(context).usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        backgroundColor: Colors.pinkAccent,
      ),
      backgroundColor: const Color(0xFFF3F3F3),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _usuario == null
              ? const Center(child: Text('Erro ao carregar dados do usuário.'))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.pinkAccent,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _usuario!.nome,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _usuario!.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const Divider(height: 40, thickness: 1.5),
                      const Text(
                        "Informações adicionais",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Você pode utilizar este app para criar eventos, visualizar seus dados e editar futuramente.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
    );
  }
}
