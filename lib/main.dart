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
  late String documenyId;
  List<String> documentIds = [];
  CollectionReference favoritesCollection =
      FirebaseFirestore.instance.collection('favorites');

  @override
  void initState() {
    super.initState();
    // initState内で非同期処理を実行
  }

  // お気に入りのトグル処理
  Future<void> _toggleFavorite(String repositoryId, int index) async {
    DocumentReference favoriteRef = favoritesCollection.doc(repositoryId);
    DocumentSnapshot favoriteDoc = await favoriteRef.get();

    if (favoriteDoc.exists) {
      // お気に入りがすでに存在する場合、削除する
      await favoriteRef.delete();
    } else {
      // お気に入りが存在しない場合、追加する
      await favoriteRef.set({
        'isFavorite': true,
      });
    }

    // お気に入り状態を更新する
    setState(() {
      _repositories[index]['isFavorite'] = !favoriteDoc.exists;
    });
  }

  Future<void> _hasFavoriteData() async {
    setState(() {
      documentIds = [];
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('favorites').get();
      querySnapshot.docs.forEach((doc) {
        if (_repositories.isNotEmpty) {
          _repositories.forEach((element) {
            if (doc.id == element['id'].toString()) {
              documentIds.add(doc.id);
            }
          });
        }
      });
    } catch (e) {
      print('Error getting document IDs: $e');
    }
  }

  Future<void> _searchRepositories(String query) async {
    final String url = 'https://api.github.com/search/repositories?q=$query';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    setState(() {
      _repositories = data['items'];
    });

    setState(() {
      documentIds = [];
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('favorites').get();
      querySnapshot.docs.forEach((doc) {
        if (_repositories.isNotEmpty) {
          _repositories.forEach((element) {
            if (doc.id == element['id'].toString()) {
              setState(() {
                documentIds.add(doc.id);
              });
            }
          });
        }
      });
    } catch (e) {
      print('Error getting document IDs: $e');
    }
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
                  onPressed: () async {
                    await _searchRepositories(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _repositories.length,
              itemBuilder: (BuildContext context, int index) {
                print(
                    'Expand + ${documentIds.contains(_repositories[0]['id'].toString())}');
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListTile(
                      title: Text(
                        _repositories[index]['full_name'] +
                            _repositories[index]['id'].toString(),
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
                      // trailing: FutureBuilder(
                      //   future: _hasFavoriteData(), // 非同期処理を行う関数
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState ==
                      //         ConnectionState.waiting) {
                      //       // データ取得中はローディングを表示
                      //       return CircularProgressIndicator();
                      //     } else if (snapshot.hasError) {
                      //       // エラーが発生した場合はエラーメッセージを表示
                      //       return Text('Error: ${snapshot.error}');
                      //     } else {
                      //       // データが取得された場合はアイコンを表示
                      //       return IconButton(
                      //         icon: Icon(Icons.favorite),
                      //         color: documenyId ==
                      //                 _repositories[index]['id'].toString()
                      //             ? Colors.red
                      //             : Colors.grey,
                      //         onPressed: () async {
                      //           await _toggleFavorite(
                      //               _repositories[index]['id'].toString(),
                      //               index);
                      //         },
                      //       );
                      //     }
                      //   },
                      // ),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite),
                        color: (_repositories[index]['isFavorite'] ??
                                false ||
                                    documentIds.contains(
                                        _repositories[index]['id'].toString()))
                            ? Colors.red
                            : Colors.grey,
                        onPressed: () async {
                          // await _hasFavoriteData(
                          //     _repositories[index]['id'].toString());
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
