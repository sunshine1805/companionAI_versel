import 'package:flutter/material.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Support"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need Immediate Help?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "If you are feeling overwhelmed, distressed, or unsafe, "
              "please reach out to the appropriate support immediately.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            const ListTile(
              leading: Icon(Icons.phone, color: Colors.red),
              title: Text("Campus Counselling Unit"),
              subtitle: Text("+60 3-11530-9988"),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: Colors.red),
              title: Text("Emergency Hotline"),
              subtitle: Text("999"),
            ),

            const Spacer(),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
