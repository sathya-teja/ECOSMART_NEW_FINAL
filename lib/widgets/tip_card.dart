import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final String tipTitle;
  final String description;

  const TipCard({
    super.key,
    required this.tipTitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tipTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
