import 'package:festora/pages/menu/home_section_page.dart';
import 'package:flutter/material.dart';
import 'package:festora/services/amizade_service.dart';
import 'package:go_router/go_router.dart';

class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});
  static const String routeName = 'amigos';

  @override
  State<AmigosPage> createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> {
  List<Map<String, dynamic>> amigos = [];
  bool carregando = true;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // carregarAmizades();
  }

  // Future<void> carregarAmizades() async {
  //   print('Iniciando carregarAmizades...');
  //   try {
  //     final aceitos = await AmizadeService().listarAceitos();
  //     print('Resposta recebida: $aceitos');
  //     setState(() {
  //       amigos = aceitos;
  //     });
  //   } catch (e) {
  //     print('Erro ao carregar amizades: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Erro ao carregar amigos.')),
  //     );
  //   } finally {
  //     print('Finalizando carregamento...');
  //     setState(() => carregando = false);
  //   }
  // }

  Future<void> _enviarSolicitacao() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await AmizadeService().enviarSolicitacao(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada!')),
      );
      _emailController.clear();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar solicitação')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEFF9),
      appBar: AppBar(
        title: const Text('Amigos'),
        backgroundColor: const Color(0xFFDAB0E8),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(HomeSectionPage.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              context.pushNamed('convites');
            },
          )
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCard(
                    title: 'Adicionar Amigo 💌',
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-mail do Amigo',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _enviarSolicitacao,
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Enviar Solicitação'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8A8E3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAmigosCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
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

  Widget _buildAmigosCard() {
    return _buildCard(
      title: '📖 Meus Amigos',
      child: amigos.isEmpty
          ? const Text('Nenhum amigo encontrado.')
          : Column(
              children: amigos
                  .map((item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFDAB0E8),
                          child: Icon(Icons.favorite, color: Colors.white),
                        ),
                        title: Text(
                          item['amigo']['nome'] ?? 'Sem nome',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.cake_outlined,
                            color: Colors.pinkAccent),
                      ))
                  .toList(),
            ),
    );
  }
}
