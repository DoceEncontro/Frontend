import 'package:festora/models/amigo_model.dart';
import 'package:festora/models/usuario_response_model.dart';
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

class _AmigosPageState extends State<AmigosPage> with TickerProviderStateMixin {
  List<Amigo> amigos = [];
  List<Amigo> pendentes = [];
  List<Amigo> recebidos = [];
  bool _isLoading = false;

  bool carregandoAceitos = true;
  bool carregandoPendentes = false;
  bool carregandoRecebidos = false;

  final TextEditingController _emailController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    carregarAmizades();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    if (_tabController.index == 1 && pendentes.isEmpty) {
      carregarPendentes();
    } else if (_tabController.index == 2 && recebidos.isEmpty) {
      carregarRecebidos();
    }
  }

  Future<void> carregarAmizades() async {
    setState(() => carregandoAceitos = true);
    try {
      final aceitos = await AmizadeService().listarAmigosAceitos();
      setState(() {
        amigos = aceitos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar amigos.')),
      );
    } finally {
      setState(() {
        carregandoAceitos = false;
      });
    }
  }

  Future<void> carregarPendentes() async {
    setState(() => carregandoPendentes = true);
    try {
      final pendentes = await AmizadeService().listarPendentes();
      setState(() {
        this.pendentes = pendentes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar amigos.')),
      );
    } finally {
      setState(() => carregandoPendentes = false);
    }
  }

  Future<void> carregarRecebidos() async {
    setState(() => carregandoRecebidos = true);
    try {
      final recebidos = await AmizadeService().listarRecebidos();
      setState(() {
        this.recebidos = recebidos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar amigos.')),
      );
    } finally {
      setState(() => carregandoRecebidos = false);
    }
  }

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

  void aceitarAmizade(String amizadeId) async {
    try {
      await AmizadeService().aceitarSolicitacao(amizadeId);

      setState(() {
        // Remover dos recebidos
        final index = recebidos.indexWhere((a) => a.amizadeId == amizadeId);
        if (index != -1) {
          final amigoAceito = recebidos.removeAt(index);
          amigos.add(amigoAceito);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido aceito com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao aceitar amizade')),
      );
    }
  }

  void excluirAmizade(String amizadeId) async {
    try {
      await AmizadeService().excluirAmizade(amizadeId);

      setState(() {
        amigos.removeWhere((amigo) => amigo.amizadeId == amizadeId);
        pendentes.removeWhere((amigo) => amigo.amizadeId == amizadeId);
        recebidos.removeWhere((amigo) => amigo.amizadeId == amizadeId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amizade excluída com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir amizade')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Aceitos'),
            Tab(text: 'Pendentes'),
            Tab(text: 'Recebidos'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCard(
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
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAmigosCard('Aceitos', amigos, carregandoAceitos),
                _buildAmigosCard('Pendentes', pendentes, carregandoPendentes),
                _buildAmigosCard('Recebidos', recebidos, carregandoRecebidos),
              ],
            ),
          ),
        ],
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

  Widget _buildAmigosCard(String title, List<Amigo> lista, bool isLoading) {
    String mensagemVazia;
    switch (title) {
      case 'Aceitos':
        mensagemVazia = 'Você não tem amigos aceitos ainda.';
        break;
      case 'Pendentes':
        mensagemVazia = 'Não há solicitações pendentes.';
        break;
      case 'Recebidos':
        mensagemVazia = 'Nenhuma solicitação recebida.';
        break;
      default:
        mensagemVazia = 'Nenhum item encontrado.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildCard(
        title: '📖 $title',
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (lista.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        mensagemVazia,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: lista.map((item) {
                      final isRecebido = title == 'Recebidos';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFDAB0E8),
                          child: Icon(Icons.favorite, color: Colors.white),
                        ),
                        title: Text(
                          item.amigo.nome,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isRecebido)
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                tooltip: 'Aceitar amizade',
                                onPressed: () => aceitarAmizade(item.amizadeId),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => excluirAmizade(item.amizadeId),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),
      ),
    );
  }
}
