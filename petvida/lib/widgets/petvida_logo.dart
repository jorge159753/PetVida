import 'package:flutter/material.dart';

/// Selo circular do PetVida, a partir do logo real (imagens/logo4.png).
///
/// O nome "PetVida" já está desenhado dentro do selo, então não é preciso
/// repeti-lo ao lado em texto — nos headers de topo, use só a logo,
/// centralizada.
class PetVidaLogo extends StatelessWidget {
  const PetVidaLogo({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/branding/logo.png', width: size, height: size);
  }
}
