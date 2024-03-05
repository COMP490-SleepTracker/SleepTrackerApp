import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tips'),
      ),
      drawer: const NavigationPanel(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your Sleep Score:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 13.0),
                Container(
                  width: 100.0,
                  height: 100.0,
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120.0, // Size of the circular progress indicator
                        height: 120.0,
                        child: CircularProgressIndicator(
                          value: 0.85, // Dummy sleep score value (85%)
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          strokeWidth: 20.0,
                        ),
                      ),
                      Text(
                        '85', // Dummy sleep score value
                        style: TextStyle(
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                TipCard(
                  title: 'Tip 1',
                  description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                ),
                TipCard(
                  title: 'Tip 2',
                  description: 'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                ),
                TipCard(
                  title: 'Tip 3',
                  description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                ),
                // Add more TipCards as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final String title;
  final String description;

  const TipCard({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
