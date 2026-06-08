import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../models/chamado.dart';
import '../../widgets/common/info_badge.dart';
import '../shared/chamado_presentation.dart';

/// Tela de detalhes de um chamado específico.
///
/// Recebe o [Chamado] por argumento de rota (ver [AppRoutes]). A edição
/// (Pessoa 7) pode ser adicionada como uma ação nesta mesma tela.
class ChamadoDetalhesPage extends StatelessWidget {
  final Chamado chamado;

  const ChamadoDetalhesPage({super.key, required this.chamado});

  @override
  Widget build(BuildContext context) {
    final double horizontal = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Chamado')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
            children: [
              _Cabecalho(chamado: chamado),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoBadge(
                    label: chamado.status.label,
                    color: chamado.status.cor,
                    icon: chamado.status.icone,
                  ),
                  InfoBadge(
                    label: 'Prioridade ${chamado.prioridade.label}',
                    color: chamado.prioridade.cor,
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _Secao(
                titulo: 'Descrição',
                child: Text(
                  chamado.descricao,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              _Secao(
                titulo: 'Informações',
                child: Column(
                  children: [
                    _LinhaInfo(
                      icon: Icons.tag,
                      label: 'Protocolo',
                      value: '#${chamado.id}',
                    ),
                    _LinhaInfo(
                      icon: chamado.categoria.icone,
                      label: 'Categoria',
                      value: chamado.categoria.label,
                    ),
                    _LinhaInfo(
                      icon: Icons.location_on_outlined,
                      label: 'Bairro',
                      value: chamado.bairro,
                    ),
                    _LinhaInfo(
                      icon: Icons.person_outline,
                      label: 'Responsável',
                      value: chamado.responsavel ?? 'Não atribuído',
                    ),
                    _LinhaInfo(
                      icon: Icons.calendar_today_rounded,
                      label: 'Aberto em',
                      value: DateFormatter.dateTime(chamado.dataCriacao),
                    ),
                    _LinhaInfo(
                      icon: Icons.schedule,
                      label: 'Tempo decorrido',
                      value: DateFormatter.relative(chamado.dataCriacao),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final Chamado chamado;

  const _Cabecalho({required this.chamado});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(chamado.categoria.icone,
              color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chamado.titulo,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                chamado.categoria.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final Widget child;

  const _Secao({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LinhaInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
