import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/submited_button.dart';

class EditCollectionPage extends StatefulWidget {
  final Collection collection; // On reçoit la collection à modifier

  EditCollectionPage({required this.collection});

  @override
  _EditCollectionPageState createState() => _EditCollectionPageState();
}

class _EditCollectionPageState extends State<EditCollectionPage> {
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
    _nomController.text = widget.collection.nom;
    _selectedArticles = List.from(
        widget.collection.articleShops); // Charger les articles sélectionnés
    _loadArticles();
  }

  Future<void> deleteCollection(
      BuildContext context, String collectionId) async {
    // Affichage de la boîte de dialogue de confirmation
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content:
              Text("Êtes-vous sûr de vouloir supprimer cette collection ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(false); // Retourne false si annulé
              },
            ),
            TextButton(
              child: Text("Supprimer"),
              onPressed: () {
                Navigator.of(context).pop(true); // Retourne true si confirmé
              },
            ),
          ],
        );
      },
    );

    // Si l'utilisateur confirme la suppression
    if (confirmation == true) {
      try {
        // Suppression de la collection dans Firestore
        await FirebaseFirestore.instance
            .collection('COLLECTION')
            .doc(collectionId)
            .delete();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Collection supprimée avec succès"),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la suppression : $e"),
            backgroundColor: AppColors.echec,
          ),
        );
      }
    }
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

  Future<void> _updateCollection() async {
    if (_nomController.text.isNotEmpty && _selectedArticles.isNotEmpty) {
      String id = widget.collection.id;
      DateTime date =
          widget.collection.date; // On garde la même date de création

      Collection updatedCollection = Collection(
        id: id,
        nom: _nomController.text,
        articleShops: _selectedArticles,
        date: date,
      );

      await _collectionCollection.doc(id).set(updatedCollection.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Collection modifiée avec succès"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Veuillez remplir le nom et sélectionner des articles")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier la Collection"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          deleteCollection(context, widget.collection.id);
        },
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
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
              "Modifier la Collection",
              _updateCollection,
            ),
          ],
        ),
      ),
    );
  }
}
