import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/chamado.dart';
import '../../services/chamado_service.dart';
import '../../widgets/cards/stats_grid.dart';
import '../../widgets/common/dashboard_header.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/lists/chamados_list.dart';
import '../chamados/chamados_filter_bar.dart';
import '../detalhes/detalhes_page.dart';

/// Tela inicial e principal do SOS Cidade.
///
/// Reúne cabeçalho institucional, cards de estatísticas, busca,
/// filtros e a lista de chamados, tudo de forma responsiva.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ChamadoService _service = ChamadoService();

  List<Chamado> _todos = [];
  bool _carregando = true;

  // Estado dos filtros e busca.
  String _busca = '';
  Categoria? _categoria;
  StatusChamado? _status;
  Prioridade? _prioridade;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final chamados = await _service.listarChamados();
    if (!mounted) return;
    setState(() {
      _todos = chamados;
      _carregando = false;
    });
  }

  /// Lista resultante após aplicar busca e filtros.
  List<Chamado> get _filtrados => _service.filtrar(
        _todos,
        busca: _busca,
        categoria: _categoria,
        status: _status,
        prioridade: _prioridade,
      );

  bool get _temFiltroAtivo =>
      _busca.isNotEmpty ||
      _categoria != null ||
      _status != null ||
      _prioridade != null;

  void _limparFiltros() {
    setState(() {
      _busca = '';
      _categoria = null;
      _status = null;
      _prioridade = null;
    });
  }

  void _abrirDetalhes(Chamado chamado) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalhesPage(chamado: chamado)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontal = Responsive.horizontalPadding(context);
    final estatisticas = _service.calcularEstatisticas(_todos);
    final filtrados = _filtrados;

    return Scaffold(
      body: SafeArea(
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _carregar,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.maxContentWidth,
                    ),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              horizontal, 16, horizontal, 0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              DashboardHeader(
                                totalChamados: estatisticas.total,
                              ),
                              const SizedBox(height: 24),
                              _SecaoTitulo(
                                titulo: 'Visão Geral',
                                icon: Icons.dashboard_outlined,
                              ),
                              const SizedBox(height: 12),
                              StatsGrid(estatisticas: estatisticas),
                              const SizedBox(height: 24),
                              _SecaoTitulo(
                                titulo: 'Chamados',
                                icon: Icons.list_alt_rounded,
                                trailing: _temFiltroAtivo
                                    ? TextButton.icon(
                                        onPressed: _limparFiltros,
                                        icon: const Icon(Icons.clear_all,
                                            size: 18),
                                        label: const Text('Limpar'),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              SearchField(
                                value: _busca,
                                onChanged: (v) => setState(() => _busca = v),
                                onClear: () => setState(() => _busca = ''),
                              ),
                              const SizedBox(height: 12),
                              ChamadosFilterBar(
                                categoria: _categoria,
                                status: _status,
                                prioridade: _prioridade,
                                onCategoria: (v) =>
                                    setState(() => _categoria = v),
                                onStatus: (v) => setState(() => _status = v),
                                onPrioridade: (v) =>
                                    setState(() => _prioridade = v),
                              ),
                              const SizedBox(height: 12),
                              _ContadorResultados(
                                quantidade: filtrados.length,
                                total: _todos.length,
                              ),
                              const SizedBox(height: 12),
                            ]),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              horizontal, 0, horizontal, 32),
                          sliver: SliverToBoxAdapter(
                            child: ChamadosList(
                              chamados: filtrados,
                              onTapChamado: _abrirDetalhes,
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
}

/// Título de seção com ícone e ação opcional à direita.
class _SecaoTitulo extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Widget? trailing;

  const _SecaoTitulo({
    required this.titulo,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

/// Exibe quantos chamados estão sendo mostrados.
class _ContadorResultados extends StatelessWidget {
  final int quantidade;
  final int total;

  const _ContadorResultados({required this.quantidade, required this.total});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        quantidade == total
            ? '$total ${total == 1 ? 'chamado' : 'chamados'}'
            : 'Exibindo $quantidade de $total chamados',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
