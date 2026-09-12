import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Selo circular do PetVida, a partir do logo real (imagens/logo4.png).
class PetVidaLogo extends StatelessWidget {
  const PetVidaLogo({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/branding/logo.png', width: size, height: size);
  }
}

/// Marca "PetVida" usada nos headers de topo: selo do logo + nome por
/// extenso, já que o texto dentro do selo fica ilegível em tamanhos
/// pequenos.
class PetVidaWordmark extends StatelessWidget {
  const PetVidaWordmark({super.key, this.logoSize = 32, this.fontSize = 26});

  final double logoSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/branding/logo.png',
          width: logoSize,
          height: logoSize,
        ),
        SizedBox(width: logoSize * 0.25),
        Text(
          'PetVida',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.laranjaTerracota,
          ),
        ),
      ],
    );
  }
}
