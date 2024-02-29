import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RepositoryDetailPage.dart';
import 'package:firebase_core/firebase_core.dart';
// テスト
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Repository Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _repositories = [];

  Future<void> _searchRepositories(String query) async {
    final String url = 'https://api.github.com/search/repositories?q=$query';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    setState(() {
      _repositories = data['items'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repository Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter repository name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchRepositories(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _repositories.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListTile(
                      title: Text(
                        _repositories[index]['full_name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        _repositories[index]['description'] ?? 'No Description',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        '⭐️: ${_repositories[index]['stargazers_count']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc('user1')
                            .set({'name': 'John', 'age': 30});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RepositoryDetailPage(
                                repository: _repositories[index]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
