import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RepositoryDetailPage.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Firestoreの参照
  final CollectionReference _likesCollection =
      FirebaseFirestore.instance.collection('likes');

  // お気に入りのトグル処理
  Future<void> _toggleFavorite(String repositoryId, int index) async {
    CollectionReference favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');
    DocumentReference favoriteRef = favoritesCollection.doc(repositoryId);
    DocumentSnapshot favoriteDoc = await favoriteRef.get();

    if (favoriteDoc.exists) {
      // お気に入りがすでに存在する場合、削除する
      await favoriteRef.delete();
    } else {
      // お気に入りが存在しない場合、追加する
      await favoriteRef.set({'isFavorite': true});
    }

    // お気に入り状態を更新する
    setState(() {
      _repositories[index]['isFavorite'] = !favoriteDoc.exists;
    });
  }

  // お気に入り状態をチェックするメソッド
  Future<bool> _isFavorite(String repositoryId) async {
    DocumentSnapshot favoriteDoc =
        await _likesCollection.doc(repositoryId).get();
    return favoriteDoc.exists;
  }

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
                      trailing: IconButton(
                        icon: Icon(Icons.favorite),
                        color: (_repositories[index]['isFavorite'] ?? false)
                            ? Colors.red
                            : Colors.grey,
                        onPressed: () async {
                          print('Heart taped!');
                          await _toggleFavorite(
                              _repositories[index]['id'].toString(), index);
                        },
                      ),
                      onTap: () {
                        // レポジトリ詳細ページに移動する処理
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
