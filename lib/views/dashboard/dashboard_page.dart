import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/chamado.dart';
import '../../providers/chamado_provider.dart';
import '../../widgets/cards/stats_grid.dart';
import '../../widgets/common/alerta_criticos.dart';
import '../../widgets/common/dashboard_header.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/lists/chamados_list.dart';
import '../chamados/chamados_filter_bar.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamadoControllerProvider);
    final controller = ref.read(chamadoControllerProvider.notifier);
    final double horizontal = Responsive.horizontalPadding(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cadastro),
        icon: const Icon(Icons.add),
        label: const Text('Novo chamado'),
      ),
      body: SafeArea(
        child: state.carregando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: controller.carregar,
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
                          sliver: SliverList.list(
                            children: [
                              DashboardHeader(
                                totalChamados: state.estatisticas.total,
                              ),
                              const SizedBox(height: 24),
                              AlertaCriticos(
                                quantidadeCriticos: state.estatisticas.criticos,
                              ),
                              const _SecaoTitulo(
                                titulo: 'Visão Geral',
                                icon: Icons.dashboard_outlined,
                              ),
                              const SizedBox(height: 12),
                              StatsGrid(estatisticas: state.estatisticas),
                              const SizedBox(height: 24),
                              _SecaoTitulo(
                                titulo: 'Chamados',
                                icon: Icons.list_alt_rounded,
                                trailing: state.filtro.vazio
                                    ? null
                                    : TextButton.icon(
                                        onPressed: controller.limparFiltros,
                                        icon: const Icon(Icons.clear_all,
                                            size: 18),
                                        label: const Text('Limpar'),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              SearchField(
                                value: state.filtro.busca,
                                onChanged: controller.buscar,
                                onClear: () => controller.buscar(''),
                              ),
                              const SizedBox(height: 12),
                              ChamadosFilterBar(
                                categoria: state.filtro.categoria,
                                status: state.filtro.status,
                                prioridade: state.filtro.prioridade,
                                onCategoria: controller.filtrarPorCategoria,
                                onStatus: controller.filtrarPorStatus,
                                onPrioridade: controller.filtrarPorPrioridade,
                              ),
                              const SizedBox(height: 12),
                              _ContadorResultados(
                                quantidade: state.filtrados.length,
                                total: state.todos.length,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              horizontal, 0, horizontal, 96),
                          sliver: SliverToBoxAdapter(
                            child: ChamadosList(
                              chamados: state.filtrados,
                              onTapChamado: (c) => _abrirDetalhes(context, c),
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

  void _abrirDetalhes(BuildContext context, Chamado chamado) {
    Navigator.pushNamed(context, AppRoutes.detalhes, arguments: chamado);
  }
}

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
        Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

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
