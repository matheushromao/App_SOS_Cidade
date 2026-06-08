import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/chamado.dart';
import '../../providers/chamado_provider.dart';
import '../shared/chamado_presentation.dart';

/// Tela de cadastro de um novo chamado.
///
/// Coleta todos os campos do domínio (título, descrição, categoria, prioridade,
/// bairro, responsável, data e status) e delega a persistência ao
/// `chamadoControllerProvider`. As validações e regras de negócio (título
/// repetido, descrição/bairro vazios) ficam no [ChamadoService]; aqui apenas
/// exibimos as mensagens de erro retornadas.
class ChamadoCadastroPage extends ConsumerStatefulWidget {
  const ChamadoCadastroPage({super.key});

  @override
  ConsumerState<ChamadoCadastroPage> createState() =>
      _ChamadoCadastroPageState();
}

class _ChamadoCadastroPageState extends ConsumerState<ChamadoCadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _responsavelCtrl = TextEditingController();

  Categoria _categoria = Categoria.buraco;
  Prioridade _prioridade = Prioridade.media;
  StatusChamado _status = StatusChamado.aberto;
  DateTime _data = DateTime.now();
  bool _salvando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _bairroCtrl.dispose();
    _responsavelCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('pt', 'BR'),
    );
    if (escolhida != null) {
      setState(() => _data = DateTime(
            escolhida.year,
            escolhida.month,
            escolhida.day,
            _data.hour,
            _data.minute,
          ));
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final corErro = Theme.of(context).colorScheme.error;

    try {
      await ref.read(chamadoControllerProvider.notifier).criar(
            titulo: _tituloCtrl.text,
            descricao: _descricaoCtrl.text,
            categoria: _categoria,
            prioridade: _prioridade,
            bairro: _bairroCtrl.text,
            responsavel: _responsavelCtrl.text,
            status: _status,
            dataCriacao: _data,
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Chamado registrado com sucesso!')),
      );
      navigator.pop();
    } catch (e) {
      // Regras de negócio (título repetido, validações) chegam aqui.
      messenger.showSnackBar(
        SnackBar(
          content: Text(_mensagemErro(e)),
          backgroundColor: corErro,
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String _mensagemErro(Object e) {
    if (e is ArgumentError) return e.message.toString();
    if (e is StateError) return e.message;
    return 'Não foi possível salvar o chamado.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Chamado')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _tituloCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    hintText: 'Ex.: Buraco na Avenida Brasil',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Informe um título com ao menos 5 caracteres.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    hintText: 'Detalhe o problema observado',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'A descrição não pode ficar vazia.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Categoria>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final c in Categoria.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icone, size: 18),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _categoria = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Prioridade>(
                  initialValue: _prioridade,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: [
                    for (final p in Prioridade.values)
                      DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 12, color: p.cor),
                            const SizedBox(width: 8),
                            Text(p.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _prioridade = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StatusChamado>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.track_changes_outlined),
                  ),
                  items: [
                    for (final s in StatusChamado.values)
                      DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(s.icone, size: 18, color: s.cor),
                            const SizedBox(width: 8),
                            Text(s.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bairroCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Bairro *',
                    hintText: 'Ex.: Centro',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o bairro.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _responsavelCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Responsável (opcional)',
                    hintText: 'Ex.: Secretaria de Obras',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: const Text('Data'),
                  subtitle: Text(DateFormatter.date(_data)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: _selecionarData,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_salvando ? 'Salvando...' : 'Registrar chamado'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
