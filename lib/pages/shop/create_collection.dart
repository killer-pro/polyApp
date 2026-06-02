import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/submited_button.dart';
import 'package:uuid/uuid.dart';

class CreateCollectionPage extends StatefulWidget {
  @override
  _CreateCollectionPageState createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  final TextEditingController _nomController = TextEditingController();
  final CollectionReference _articleCollection =
      FirebaseFirestore.instance.collection('ARTICLE');
  final CollectionReference _collectionCollection =
      FirebaseFirestore.instance.collection('COLLECTION');

  List<ArticleShop> _articles = [];
  List<ArticleShop> _selectedArticles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    QuerySnapshot querySnapshot = await _articleCollection.get();
    setState(() {
      _articles = querySnapshot.docs
          .map(
              (doc) => ArticleShop.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _createCollection() async {
    if (_nomController.text.isNotEmpty && _selectedArticles.isNotEmpty) {
      String id = const Uuid().v4();
      DateTime date = DateTime.now();

      Collection newCollection = Collection(
        id: id,
        nom: _nomController.text,
        articleShops: _selectedArticles,
        date: date,
      );

      await _collectionCollection.doc(id).set(newCollection.toJson());

      _nomController.clear();
      setState(() {
        _selectedArticles.clear();
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Collection créée avec succès"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez remplir le nom et sélectionner des articles"),
          backgroundColor: AppColors.echec,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Créer une Collection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: "Nom de la Collection",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Sélectionner des Articles",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_articles[index].titre),
                    value: _selectedArticles.contains(_articles[index]),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedArticles.add(_articles[index]);
                        } else {
                          _selectedArticles.remove(_articles[index]);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SubmittedButton(
              "Créer la Collection",
              _createCollection,
            ),
          ],
        ),
      ),
    );
  }
}
