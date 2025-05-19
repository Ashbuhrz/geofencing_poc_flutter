import 'package:flutter/material.dart';

class PermissionCard extends StatelessWidget {
  final String name;
  final String status;
  final VoidCallback onRequest;

  const PermissionCard({
    super.key,
    required this.name,
    required this.status,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGranted = status == "Granted";
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isGranted ? Icons.check_circle : Icons.error,
              color: isGranted ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isGranted ? "Granted" : "Not Granted",
                    style: TextStyle(
                      fontSize: 14,
                      color: isGranted ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            if (!isGranted)
              ElevatedButton(
                onPressed: onRequest,
                child: const Text("Request"),
              ),
          ],
        ),
      ),
    );
  }
}
