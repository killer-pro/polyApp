import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/pages/annonce/edit_categorie.dart';
import 'package:new_app/services/annonce_service.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'dart:io';

import '../../models/categorie.dart';

class AddCategoriePage extends StatefulWidget {
  @override
  _AddCategoriePageState createState() => _AddCategoriePageState();
}

class _AddCategoriePageState extends State<AddCategoriePage> {
  final TextEditingController _libelleController = TextEditingController();
  AnnonceService _annonceService = AnnonceService();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      String fileName = '${_libelleController.text}_logo';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('categories/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erreur lors du téléchargement de l\'image: $e');
      return null;
    }
  }

  Future<void> _ajouterCategorie() async {
    if (_libelleController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Veuillez remplir tous les champs et ajouter un logo."),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? logoUrl = await _uploadImageToStorage(_imageFile!);
      if (logoUrl != null) {
        Categorie categorie = Categorie(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          libelle: _libelleController.text,
          logo: logoUrl,
        );

        _annonceService.addCategorie(categorie);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Catégorie ajoutée avec succès !"),
        ));

        _libelleController.clear();
        setState(() {
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erreur lors de l'ajout de l'image."),
        ));
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la catégorie: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de l'ajout de la catégorie."),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Catégorie'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _libelleController,
              decoration: InputDecoration(labelText: 'Libellé de la Catégorie'),
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? Text('Aucune image sélectionnée.')
                : Image.file(_imageFile!, height: 150),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Choisir un logo'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? AppLoader()
                : ElevatedButton(
                    onPressed: _ajouterCategorie,
                    child: Text('Ajouter la Catégorie'),
                  ),
            SizedBox(
              height: 50,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('CATEGORIE')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: AppLoader());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Erreur lors de la récupération des catégories.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucune catégorie trouvée.'));
                }

                // Récupérer les catégories à partir des documents Firestore

                List<DocumentSnapshot> categories = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true, // Ajouté pour adapter la hauteur
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    // Chaque catégorie
                    var categorieDoc = categories[index];

                    // Convertir le DocumentSnapshot en un objet Categorie
                    Categorie categorie = Categorie(
                      id: categorieDoc.id, // L'ID du document
                      libelle: categorieDoc['libelle'],
                      logo: categorieDoc['logo'],
                    );

                    return ListTile(
                      onTap: () {
                        changerPage(
                            context, EditCategoriePage(categorie: categorie));
                      },
                      leading: categorie.logo.isNotEmpty
                          ? SizedBox(
                        width: 50,
                        child: Image(
                          image: ResizeImage(
                            CachedNetworkImageProvider(categorie.logo),
                            width: 140,
                          ),
                          fit: BoxFit.cover,
                        ),
                      )

                          : Icon(Icons.image_not_supported),
                      title: Text(categorie.libelle),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
