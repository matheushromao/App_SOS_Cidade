import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tela de cadastro de chamado — ESQUELETO (responsável: Pessoa 6).
///
/// A fundação já entrega tudo o que esta tela precisa:
/// - `ref.read(chamadoControllerProvider.notifier).criar(...)` para persistir;
/// - validação centralizada em `ChamadoService` (lança [ArgumentError]);
/// - enums `Categoria`/`Prioridade` para popular os campos.
///
/// Mantida como placeholder para não bloquear a navegação e deixar claro o
/// contrato de integração, sem implementar a tela inteira aqui.
class ChamadoCadastroPage extends ConsumerWidget {
  const ChamadoCadastroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Chamado')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_note_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Formulário de cadastro a ser implementado pela Pessoa 6.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Use chamadoControllerProvider.notifier.criar(...).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
