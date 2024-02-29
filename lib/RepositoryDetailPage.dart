import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RepositoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> repository;

  RepositoryDetailPage({required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repository Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Name:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              repository['full_name'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              repository['description'] ?? 'N/A',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '⭐️', // iPhoneの星の絵文字
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(width: 8),
                Text(
                  repository['stargazers_count'].toString(),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _launchURL(repository['html_url']);
              },
              child: Text('Open in GitHub'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
