import 'package:flutter/material.dart';
import 'package:festora/services/amizade_service.dart';
import 'package:festora/services/convite_service.dart';

class ConvitesPage extends StatefulWidget {
  const ConvitesPage({super.key});
  static const String routeName = 'convites';

  @override
  State<ConvitesPage> createState() => _ConvitesPageState();
}

class _ConvitesPageState extends State<ConvitesPage> {
  List<Map<String, dynamic>> convites = [];
  List<Map<String, dynamic>> pendentes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarConvites();
  }

  Future<void> carregarConvites() async {
    try {
      final convitesRecebidos = await ConviteService().listarConvitesUsuario();
      final pendentesLista = await AmizadeService().listarPendentes();
      setState(() {
        convites = convitesRecebidos;
        // pendentes = pendentesLista;
        carregando = false;
      });
    } catch (_) {
      setState(() => carregando = false);
    }
  }

  Future<void> aceitar(String amizadeId) async {
    try {
      await AmizadeService().aceitarSolicitacao(amizadeId);
      await carregarConvites();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amizade aceita!')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao aceitar amizade')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEFF9),
      appBar: AppBar(
        title: const Text('Convites e Pendentes'),
        backgroundColor: const Color(0xFFDAB0E8),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildCard(
                          title: '📬 Convites Recebidos',
                          child: convites.isEmpty
                              ? const Text('Nenhum convite recebido.')
                              : Column(
                                  children: convites
                                      .map((item) => ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const CircleAvatar(
                                              backgroundColor: Color(0xFFA3E4D7),
                                              child: Icon(Icons.mail_outline, color: Colors.white),
                                            ),
                                            title: Text(item['titulo'] ?? 'Convite'),
                                            subtitle: Text(item['descricao'] ?? ''),
                                          ))
                                      .toList(),
                                ),
                        ),
                        const SizedBox(height: 20),
                        _buildCard(
                          title: '⏳ Solicitações de Amizade Pendentes',
                          child: pendentes.isEmpty
                              ? const Text('Nenhuma solicitação.')
                              : Column(
                                  children: pendentes
                                      .map((item) => ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const CircleAvatar(
                                              backgroundColor: Color(0xFFFFC0CB),
                                              child: Icon(Icons.person_outline, color: Colors.white),
                                            ),
                                            title: Text(item['amigo']['nome'] ?? 'Sem nome'),
                                            trailing: ElevatedButton(
                                              onPressed: () => aceitar(item['amizadeId']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFE1C2F7),
                                                foregroundColor: Colors.black,
                                              ),
                                              child: const Text('Aceitar'),
                                            ),
                                          ))
                                      .toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
