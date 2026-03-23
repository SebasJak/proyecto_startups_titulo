import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Projects Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard('Total Views', '12,450', Icons.visibility, Colors.blue),
            const SizedBox(height: 16),
            _buildStatCard('Total Likes', '3,210', Icons.favorite, Colors.red),
            const SizedBox(height: 16),
            _buildStatCard('Interested Investors', '45', Icons.people, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
