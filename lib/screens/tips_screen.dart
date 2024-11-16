import 'package:flutter/material.dart';
import '../widgets/tip_card.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eco Tips"),
      ),
      body: ListView(
        children: const [
          TipCard(
            tipTitle: "Reuse Bags",
            description: "Carry reusable bags to reduce plastic waste.",
          ),
          TipCard(
            tipTitle: "Save Water",
            description: "Take shorter showers to conserve water.",
          ),
        ],
      ),
    );
  }
}
