import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Selo circular do PetVida (patinha + nome), recriado em código a partir
/// do logo do Figma (imagens/logo1.jpg), já que o arquivo original tem o
/// fundo transparente "queimado" em xadrez e não pode ser usado direto.
class PetVidaLogo extends StatelessWidget {
  const PetVidaLogo({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cremeSuave,
        border: Border.all(color: AppColors.amareloPorDoSol, width: size * 0.03),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: size * 0.4, color: AppColors.laranjaSolar),
          SizedBox(height: size * 0.04),
          Text(
            'PetVida',
            style: TextStyle(
              fontSize: size * 0.16,
              fontWeight: FontWeight.bold,
              color: AppColors.laranjaTerracota,
            ),
          ),
        ],
      ),
    );
  }
}
