import 'package:flutter/material.dart';

class LabelCampo extends StatelessWidget {
  final String label;

  const LabelCampo({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }
}
