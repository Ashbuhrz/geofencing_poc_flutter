import 'package:flutter/material.dart';
import 'package:geofencingpoc/utils/sharePreference.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<String> _eventRecords = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadEventRecords();
  }

  Future<void> _loadEventRecords() async {
    List<String> events = await loadEventRecords();
    setState(() {
      _eventRecords = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demo App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Text('Geofence Events:', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () async {
                await clearRecords();
                _loadEventRecords();
              },
              child: Text('Clear List'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _eventRecords.length,
                itemBuilder:
                    (context, index) =>
                        ListTile(title: Text(_eventRecords[index])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
