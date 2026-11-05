import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Portes aceitos no cadastro do pet. Substituem o campo "Raça" porque
/// tutores de SRD (vira-latas) não sabem a raça exata (ver CHANGELOG.md).
const portesPet = ['Pequeno', 'Médio', 'Grande'];

/// Seletor de porte com botões grandes e patinhas de tamanhos diferentes,
/// usado nos formulários de cadastro e edição do pet.
class PorteSelector extends StatelessWidget {
  const PorteSelector({
    super.key,
    required this.selecionado,
    required this.onChanged,
  });

  final String? selecionado;
  final ValueChanged<String> onChanged;

  static const _tamanhosIcone = [18.0, 24.0, 30.0];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Porte',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < portesPet.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _PorteBotao(
                  label: portesPet[i],
                  tamanhoIcone: _tamanhosIcone[i],
                  selecionado: selecionado == portesPet[i],
                  onTap: () => onChanged(portesPet[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PorteBotao extends StatelessWidget {
  const _PorteBotao({
    required this.label,
    required this.tamanhoIcone,
    required this.selecionado,
    required this.onTap,
  });

  final String label;
  final double tamanhoIcone;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final corConteudo = selecionado ? Colors.white : AppColors.laranjaTerracota;
    return Semantics(
      button: true,
      selected: selecionado,
      label: 'Porte $label',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 72,
          decoration: BoxDecoration(
            color: selecionado ? AppColors.laranjaTerracota : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.laranjaTerracota, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: tamanhoIcone, color: corConteudo),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: corConteudo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
