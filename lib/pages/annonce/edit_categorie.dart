import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/categorie.dart';
import '../../services/annonce_service.dart';
import 'package:new_app/widgets/app_loader.dart';

class EditCategoriePage extends StatefulWidget {
  final Categorie categorie;

  EditCategoriePage({required this.categorie});

  @override
  _EditCategoriePageState createState() => _EditCategoriePageState();
}

class _EditCategoriePageState extends State<EditCategoriePage> {
  final TextEditingController _libelleController = TextEditingController();
  AnnonceService _annonceService = AnnonceService();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _libelleController.text = widget.categorie.libelle;
  }

  Future<void> _supprimerCategorie(String categorieId) async {
    bool confirmation = await _showConfirmationDialog();
    if (confirmation) {
      try {
        _annonceService.deleteCategorie(categorieId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Catégorie supprimée avec succès")),
        );
      } catch (e) {
        debugPrint('Erreur lors de la suppression de la catégorie: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erreur lors de la suppression de la catégorie")),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirmation de suppression'),
              content:
                  Text('Êtes-vous sûr de vouloir supprimer cette catégorie ?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: Text('Confirmer'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

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

  Future<void> _modifierCategorie() async {
    if (_libelleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Le libellé ne peut pas être vide."),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? logoUrl = widget.categorie.logo;

      if (_imageFile != null) {
        String? uploadedUrl = await _uploadImageToStorage(_imageFile!);
        if (uploadedUrl != null) {
          logoUrl = uploadedUrl;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur lors du téléchargement de l'image."),
          ));
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      Categorie updatedCategorie = Categorie(
        id: widget.categorie.id,
        libelle: _libelleController.text,
        logo: logoUrl,
      );

      _annonceService.updateCategorie(updatedCategorie);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Catégorie modifiée avec succès !"),
      ));

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erreur lors de la modification de la catégorie: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de la modification de la catégorie."),
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
        title: Text('Modifier la Catégorie'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _supprimerCategorie(widget.categorie.id);
        },
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
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
                ? widget.categorie.logo.isNotEmpty
                    ? Image.network(widget.categorie.logo, height: 150)
                    : Text('Aucune image sélectionnée.')
                : Image.file(_imageFile!, height: 150),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Choisir un nouveau logo'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? AppLoader()
                : ElevatedButton(
                    onPressed: _modifierCategorie,
                    child: Text('Modifier la Catégorie'),
                  ),
          ],
        ),
      ),
    );
  }
}
