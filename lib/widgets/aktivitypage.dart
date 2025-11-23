import 'package:flutter/material.dart';
import 'activity_pages.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aktivitas Saya'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildActivityItem(
            context,
            'Favorit',
            Icons.favorite,
            Color(0xFFE91E63),
            FavoritPage(),
          ),
          _buildActivityItem(
            context,
            'Like',
            Icons.thumb_up,
            Color(0xFF2196F3),
            LikePage(),
          ),
          _buildActivityItem(
            context,
            'Booking',
            Icons.calendar_today,
            Color(0xFF4CAF50),
            BookingPage(),
          ),
          _buildActivityItem(
            context,
            'Sparring',
            Icons.sports_martial_arts,
            Color(0xFFFF9800),
            SparringPage(),
          ),
          _buildActivityItem(
            context,
            'Mabar',
            Icons.group,
            Color(0xFF9C27B0),
            MabarPage(),
          ),
          _buildActivityItem(
            context,
            'Riwayat',
            Icons.history,
            Color(0xFF607D8B),
            RiwayatPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}