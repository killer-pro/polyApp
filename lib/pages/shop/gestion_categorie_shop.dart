import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/categorie_shop.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:uuid/uuid.dart';

class CategorieShopPage extends StatefulWidget {
  @override
  _CategorieShopPageState createState() => _CategorieShopPageState();
}

class _CategorieShopPageState extends State<CategorieShopPage> {
  final TextEditingController _libelleController = TextEditingController();
  final ShopService _shopService = ShopService();
  final CollectionReference<Map<String, dynamic>> _categorieShopCollection =
      FirebaseFirestore.instance.collection("CATEGORIESHOP");

  List<CategorieShop> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categories = await _shopService.getAllCategorieShop();
    setState(() {});
  }

  Future<void> _createCategorie() async {
    if (_libelleController.text.isNotEmpty) {
      String id = const Uuid().v4();
      CategorieShop newCategorie =
          CategorieShop(id: id, libelle: _libelleController.text);

      await _categorieShopCollection.doc(id).set(newCategorie.toJson());

      _libelleController.clear();
      _loadCategories();
    }
  }

  Future<void> _deleteCategorie(CategorieShop categorie) async {
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Voulez-vous vraiment supprimer cette catégorie ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Fermer la boîte de dialogue
              },
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmer la suppression
              },
              child: Text("Confirmer"),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await _categorieShopCollection.doc(categorie.id).delete();
      _loadCategories();
    }
  }

  // Méthode pour modifier une catégorie
  Future<void> _editCategorie(CategorieShop categorie) async {
    final TextEditingController _editLibelleController =
        TextEditingController(text: categorie.libelle);

    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modifier la catégorie"),
          content: TextField(
            controller: _editLibelleController,
            decoration: InputDecoration(labelText: "Nom de la catégorie"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Fermer sans modifier
              },
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmer la modification
              },
              child: Text("Modifier"),
            ),
          ],
        );
      },
    );

    if (confirmation == true && _editLibelleController.text.isNotEmpty) {
      // Mettre à jour la catégorie dans Firestore
      await _categorieShopCollection.doc(categorie.id).update({
        'libelle': _editLibelleController.text,
      });
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Gestion des Catégories"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Créer une catégorie shop',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _libelleController,
              decoration: InputDecoration(
                labelText: "Nom de la catégorie",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createCategorie,
              child: Text("Ajouter Catégorie"),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Liste des catégories',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: _categories.isNotEmpty
                  ? ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Container(
                            decoration: BoxDecoration(
                              color: AppColors.gray,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Text(_categories[index].libelle),
                          ),
                          onTap: () {
                            _editCategorie(_categories[index]);
                          },
                          trailing: IconButton(
                            onPressed: () {
                              _deleteCategorie(_categories[index]);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: Text("Aucune catégorie disponible")),
            ),
          ],
        ),
      ),
    );
  }
}
