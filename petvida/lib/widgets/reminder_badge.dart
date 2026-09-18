import 'package:flutter/material.dart';

/// Selo colorido usado para avisar o tutor sobre o status de uma
/// próxima dose de vacina ou medicamento (atrasada, vence hoje, etc.).
class ReminderBadge extends StatelessWidget {
  const ReminderBadge({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
