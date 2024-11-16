import 'package:flutter/material.dart';

class RewardCard extends StatelessWidget {
  final String rewardTitle;
  final String description;
  final IconData icon;

  const RewardCard({
    super.key,
    required this.rewardTitle,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.amber),
        title: Text(rewardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}
