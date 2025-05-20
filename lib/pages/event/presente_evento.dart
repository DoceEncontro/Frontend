import 'package:festora/controllers/presente_controller.dart';
import 'package:festora/models/criar_presente_model.dart';
import 'package:festora/models/evento_details_model.dart';
import 'package:festora/models/presente_model.dart';
import 'package:festora/services/evento_service.dart';
import 'package:festora/services/presente_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:festora/services/token_service.dart';
import 'package:provider/provider.dart';

class PresenteEventoPage extends StatefulWidget {
  final EventoDetails evento;

  const PresenteEventoPage({super.key, required this.evento});

  static const String routeName = 'presente-evento';
  static const String routePath = '/presente-evento';

  @override
  State<PresenteEventoPage> createState() => _PresenteEventoPageState();
}

class _PresenteEventoPageState extends State<PresenteEventoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _carregando = false;
  late EventoDetails _evento;

  late PresenteController presenteController;

  @override
  void initState() {
    super.initState();
    _evento = widget.evento;
    presenteController =
        Provider.of<PresenteController>(context, listen: false);
    carregarPresentes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _excluirPresente(String presenteId) async {
    setState(() {
      _carregando = true;
    });

    try {
      bool sucesso = await PresenteService().removerPresente(presenteId);

      if (sucesso) {
        setState(() {
          presenteController.excluirPresentePorId(presenteId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presente excluído com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir presente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> cancelarEntrega(String presenteId) async {
    setState(() {
      _carregando = true;
    });

    try {
      (bool, PresenteModel) response =
          await PresenteService().removerResponsavel(presenteId);

      if (response.$1) {
        presenteController.editarPresentePorId(response.$2);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrega cancelada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cancelar entrega.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _adicionarResponsavel(String presenteId) async {
    setState(() {
      _carregando = true;
    });

    try {
      (bool, PresenteModel) sucesso =
          await PresenteService().adicionarResponsavel(presenteId);

      if (sucesso.$1) {
        presenteController.editarPresentePorId(sucesso.$2);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Responsável adicionado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao adicionar responsável.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _cadastrarPresente(String eventoId) async {
    final presente = PresenteCreateModel(
        titulo: _tituloController.text, descricao: _descricaoController.text);
    setState(() {
      _carregando = true;
    });
    try {
      (bool, PresenteModel) response =
          await PresenteService().criarPresente(eventoId, presente);
      if (response.$1) {
        presenteController.adicionarPresente(response.$2);
        // Exibe uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presente cadastrado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar presente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> carregarPresentes() async {
    setState(() {
      _carregando = true;
    });

    if (!presenteController.isCarregado) {
      try {
        final presentes = await PresenteService().buscarPresentes(_evento.id);
        presenteController.setPresentes(presentes);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
    setState(() {
      _carregando = false;
    });
  }

  void _abrirModalCadastro() {
    _tituloController.clear();
    _descricaoController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Presente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Adicionar'),
            onPressed: _carregando
                ? null
                : () async {
                    await _cadastrarPresente(_evento.id);
                    Navigator.of(context)
                        .pop(); // Fecha o modal após o cadastro
                  },
          ),
        ],
      ),
    );
  }

  void _abrirModalEditar(PresenteModel presente) {
    _tituloController.text = presente.titulo;
    _descricaoController.text = presente.descricao;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Presente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Salvar'),
            onPressed: _carregando
                ? null
                : () async {
                    setState(() => _carregando = true);
                    try {
                      (bool, PresenteModel) response =
                          await PresenteService().editarPresente(
                        presente.id,
                        PresenteCreateModel(
                          titulo: _tituloController.text,
                          descricao: _descricaoController.text,
                        ),
                      );

                      if (response.$1) {
                        presenteController.editarPresentePorId(response.$2);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Presente editado com sucesso!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Erro ao editar presente.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: ${e.toString()}')),
                      );
                    } finally {
                      setState(() => _carregando = false);
                    }
                  },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentes = presenteController.presentes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presentes'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do presente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_evento.isAutor)
              ElevatedButton.icon(
                icon: const Icon(Icons.card_giftcard),
                label: const Text('Cadastrar'),
                onPressed: _carregando ? null : _abrirModalCadastro,
              ),
            const SizedBox(height: 30),
            const Text(
              'Presentes já cadastrados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: presentes.isEmpty
                  ? const Text('Nenhum presente cadastrado.')
                  : ListView.builder(
                      itemCount: presentes.length,
                      itemBuilder: (context, index) {
                        final presente = presentes[index];
                        return Card(
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Título e descrição à esquerda
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        presente.titulo,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        presente.descricao,
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: 24,
                                      child: presente.responsaveis.isNotEmpty
                                          ? const Icon(Icons.check_circle,
                                              color: Colors.pinkAccent)
                                          : null,
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'editar') {
                                          _abrirModalEditar(presente);
                                        } else if (value == 'excluir') {
                                          _excluirPresente(presente.id);
                                        } else if (value == 'entregar') {
                                          _adicionarResponsavel(presente.id);
                                        } else if (value == 'cancelar') {
                                          cancelarEntrega(presente.id);
                                        }
                                      },
                                      itemBuilder: (context) {
                                        final List<PopupMenuEntry<String>>
                                            items = [];

                                        // Para todos, opção Entregar ou Cancelar
                                        if (presente.isResponsavel) {
                                          items.add(
                                            const PopupMenuItem(
                                              value: 'cancelar',
                                              child: Text('Cancelar Entrega'),
                                            ),
                                          );
                                        } else {
                                          items.add(
                                            const PopupMenuItem(
                                              value: 'entregar',
                                              child: Text('Entregar'),
                                            ),
                                          );
                                        }

                                        // Se for autor, adiciona Editar e Excluir
                                        if (_evento.isAutor) {
                                          items.add(const PopupMenuDivider());
                                          items.add(
                                            const PopupMenuItem(
                                              value: 'editar',
                                              child: Text('Editar'),
                                            ),
                                          );
                                          items.add(
                                            const PopupMenuItem(
                                              value: 'excluir',
                                              child: Text('Excluir'),
                                            ),
                                          );
                                        }

                                        return items;
                                      },
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 16.0, bottom: 8.0),
                                child: Text(
                                  'Quem vai entregar:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (presente.responsaveis.isEmpty)
                                const Padding(
                                  padding:
                                      EdgeInsets.only(left: 16.0, bottom: 8.0),
                                  child:
                                      Text('Ninguém se responsabilizou ainda.'),
                                )
                              else
                                ...presente.responsaveis.map((r) => ListTile(
                                      leading: const Icon(Icons.person),
                                      title: Text(r.nome),
                                    )),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
