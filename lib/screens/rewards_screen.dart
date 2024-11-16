import 'package:flutter/material.dart';
import '../widgets/reward_card.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rewards"),
      ),
      body: ListView(
        children: const [
          RewardCard(
            rewardTitle: "Gold Star",
            description: "Earned for reaching 100 points!",
            icon: Icons.star,
          ),
          RewardCard(
            rewardTitle: "Recycling Champion",
            description: "Awarded for 50 disposals.",
            icon: Icons.eco,
          ),
        ],
      ),
    );
  }
}
