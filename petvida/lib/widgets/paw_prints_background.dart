import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Patinhas decorativas de fundo (ver imagens/tela inicial.png).
///
/// Envolve [child] com patinhas sutis (baixa opacidade) espalhadas pelos
/// cantos da tela, sem interferir na leitura do conteúdo. Usa alinhamento
/// fracionário para se adaptar a telas pequenas e grandes.
class PawPrintsBackground extends StatelessWidget {
  const PawPrintsBackground({super.key, required this.child});

  final Widget child;

  static const _paws = [
    _PawSpec(alignment: Alignment(-0.92, -0.6), size: 44, angle: -0.5),
    _PawSpec(alignment: Alignment(0.95, -0.15), size: 58, angle: 0.4),
    _PawSpec(alignment: Alignment(-0.88, 0.55), size: 50, angle: 0.3),
    _PawSpec(alignment: Alignment(0.92, 0.9), size: 42, angle: -0.35),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(children: [for (final paw in _paws) _Paw(paw)]),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _PawSpec {
  const _PawSpec({
    required this.alignment,
    required this.size,
    required this.angle,
  });

  final Alignment alignment;
  final double size;
  final double angle;
}

class _Paw extends StatelessWidget {
  const _Paw(this.spec);

  final _PawSpec spec;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: spec.alignment,
      child: Opacity(
        opacity: 0.3,
        child: Transform.rotate(
          angle: spec.angle,
          child: Icon(
            Icons.pets,
            size: spec.size,
            color: AppColors.amareloPorDoSol,
          ),
        ),
      ),
    );
  }
}
