import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Indicador de carregamento com patinhas (âncora emocional do PetVida).
///
/// Três patinhas acendem em sequência, como passos de um pet andando.
/// Substitui o `CircularProgressIndicator` padrão em todo o app; [size]
/// é a altura de cada patinha e [color] permite usar a versão branca dentro
/// de botões laranja.
class PawLoading extends StatefulWidget {
  const PawLoading({
    super.key,
    this.size = 28,
    this.color = AppColors.laranjaTerracota,
  });

  final double size;
  final Color color;

  @override
  State<PawLoading> createState() => _PawLoadingState();
}

class _PawLoadingState extends State<PawLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : widget.size * 0.15,
                    // Alterna as patinhas para cima/baixo, como pegadas.
                    top: i.isOdd ? 0 : widget.size * 0.35,
                    bottom: i.isOdd ? widget.size * 0.35 : 0,
                  ),
                  child: Opacity(
                    opacity: _opacidade(i),
                    child: Transform.rotate(
                      angle: i.isOdd ? 0.25 : -0.25,
                      child: Icon(
                        Icons.pets,
                        size: widget.size,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Cada patinha fica mais forte durante seu terço do ciclo.
  double _opacidade(int indice) {
    final fase = (_controller.value * 3 - indice) % 3;
    return fase < 1 ? 1.0 - fase * 0.75 : 0.25;
  }
}
