import 'package:flutter/material.dart';

class ActivityLogWidget extends StatelessWidget {
  final List<String> activityLog;
  final VoidCallback onViewFullHistory;

  const ActivityLogWidget({
    Key? key,
    required this.activityLog,
    required this.onViewFullHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: onViewFullHistory,
              icon: const Icon(Icons.history),
              label: const Text('Full History'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: activityLog.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No activity recorded today',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: activityLog.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = activityLog.length - 1 - index;
                    final activity = activityLog[reversedIndex];
                    
                    // Parse the activity to determine icon and color
                    IconData icon;
                    Color color;
                    
                    if (activity.contains('Checked In')) {
                      icon = Icons.login;
                      color = Colors.green;
                    } else if (activity.contains('Checked Out')) {
                      icon = Icons.logout;
                      color = Colors.red;
                    } else if (activity.contains('Break Started')) {
                      icon = Icons.pause;
                      color = Colors.orange;
                    } else if (activity.contains('Break Ended')) {
                      icon = Icons.play_arrow;
                      color = Colors.green;
                    } else {
                      icon = Icons.info;
                      color = Colors.blue;
                    }
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(
                          activity.split(' - ')[1],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          activity.split(' - ')[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
