import 'package:festora/controllers/amigos_controller.dart';
import 'package:festora/exceptions/api_error_exception.dart';
import 'package:festora/models/amigo_model.dart';
import 'package:festora/models/usuario_response_model.dart';
import 'package:festora/pages/menu/home_section_page.dart';
import 'package:flutter/material.dart';
import 'package:festora/services/amizade_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});
  static const String routeName = 'amigos';

  @override
  State<AmigosPage> createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> with TickerProviderStateMixin {
  bool _isLoading = false;

  bool carregandoAceitos = true;
  bool carregandoPendentes = false;
  bool carregandoRecebidos = false;

  late final AmigosController amigosController;

  final TextEditingController _emailController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    amigosController = Provider.of<AmigosController>(context, listen: false);

    carregarAmizades();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    if (_tabController.index == 1 && !Provider.of<AmigosController>(context, listen: false).pendCarregados) {
      carregarPendentes();
    } else if (_tabController.index == 2 && !Provider.of<AmigosController>(context, listen: false).recebCarregados) {
      carregarRecebidos();
    }
  }

  Future<void> carregarAmizades() async {
    setState(() => carregandoAceitos = true);

    if (!Provider.of<AmigosController>(context, listen: false).amgCarregados) {
      try {
        final aceitos = await AmizadeService().listarAmigosAceitos();

        amigosController.setAmigos(aceitos);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar amigos.')),
        );
      }
    }
    setState(() {
      carregandoAceitos = false;
    });
  }

  Future<void> carregarPendentes() async {
    setState(() => carregandoPendentes = true);
    try {
      final pendentes = await AmizadeService().listarPendentes();

      amigosController.setPendentes(pendentes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar amigos.')),
      );
    }
    setState(() => carregandoPendentes = false);
  }

  Future<void> carregarRecebidos() async {
    setState(() => carregandoRecebidos = true);
    try {
      final recebidos = await AmizadeService().listarRecebidos();

      amigosController.setRecebidos(recebidos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar amigos.')),
      );
    }
    setState(() => carregandoRecebidos = false);
  }

  Future<void> _enviarSolicitacao() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final novoAmigo = await AmizadeService().enviarSolicitacao(email);

      amigosController.enviarPedido(novoAmigo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada!')),
      );
      _emailController.clear();
    } catch (e) {
      print(e);
      String mensagemErro;

      if (e is ApiException) {
        mensagemErro = e.error.message; // pega a mensagem do ApiError
      } else {
        mensagemErro =
            "Ocorreu um erro inesperado."; // transforma o erro genérico em string
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void aceitarAmizade(String amizadeId) async {
    try {
      await AmizadeService().aceitarSolicitacao(amizadeId);

      amigosController.aceitarAmigo(amizadeId);

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

      amigosController.removerAmizade(amizadeId);

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
                _buildAmigosCard(
                    'Aceitos',
                    Provider.of<AmigosController>(context).amigos,
                    carregandoAceitos),
                _buildAmigosCard(
                    'Pendentes',
                    Provider.of<AmigosController>(context).pendentes,
                    carregandoPendentes),
                _buildAmigosCard(
                    'Recebidos',
                    Provider.of<AmigosController>(context).recebidos,
                    carregandoRecebidos),
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
