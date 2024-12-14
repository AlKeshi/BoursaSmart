import 'dart:convert';
// Removed: import 'package:boursa/home_page.dart'; // This causes a circular dependency
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Fixed import and added semicolon.

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState(); // Updated createState to return _NewsPageState
}

class _NewsPageState extends State<NewsPage> {
  // For demonstration, we'll use a static list of news items.
  // In a real app, you could fetch this data from an API.
  final List<Map<String, String>> _newsItems = [
    {
      'title': 'Market hits a new high',
      'subtitle': 'The market rose by 2.3% today, hitting all-time records.',
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse varius enim in eros elementum tristique...'
    },
    {
      'title': 'Tech stocks rally',
      'subtitle': 'Tech sector sees strong gains as investors pile in.',
      'content':
          'Nulla facilisi. Phasellus non sollicitudin ligula. Donec id orci mollis, vehicula nisl ac, laoreet nulla...'
    },
    {
      'title': 'Bourse announces new policies',
      'subtitle': 'Regulatory changes could shape the future trading environment.',
      'content':
          'Curabitur consequat, massa non faucibus ullamcorper, est lacus euismod tortor, vitae convallis sapien elit a nisl...'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background color
      appBar: AppBar(
        title: const Text('Latest News', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: ListView.builder(
        itemCount: _newsItems.length,
        itemBuilder: (context, index) {
          final newsItem = _newsItems[index];
          return Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                newsItem['title'] ?? 'No Title',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                newsItem['subtitle'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                // On tap, navigate to a detailed news page or show a dialog with more info
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailPage(newsItem: newsItem),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// **Optional: Create a Detailed News Page**
class NewsDetailPage extends StatelessWidget {
  final Map<String, String> newsItem;

  const NewsDetailPage({Key? key, required this.newsItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(newsItem['title'] ?? 'News Detail'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          newsItem['content'] ?? 'No Content',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}