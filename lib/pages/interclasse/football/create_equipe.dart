import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/pages/interclasse/football/edit_equipe.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'dart:io';
import '/models/equipe.dart';

class CreateEquipePage extends StatefulWidget {
  @override
  _CreateEquipePageState createState() => _CreateEquipePageState();
}

class _CreateEquipePageState extends State<CreateEquipePage> {
  final TextEditingController _nomController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  // Fonction pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fonction pour uploader une image dans Firebase Storage
  Future<String?> _uploadImageToStorage(File image) async {
    try {
      String fileName = '${_nomController.text}_logo';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('equipes/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erreur lors du téléchargement de l\'image: $e');
      return null;
    }
  }

  // Fonction pour ajouter une équipe
  Future<void> _ajouterEquipe() async {
    if (_nomController.text.isEmpty || _imageFile == null) {
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
        Equipe equipe = Equipe(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Générer un ID unique
          nom: _nomController.text,
          logo: logoUrl,
          joueurs: [], // Liste vide de joueurs au début
        );

        await FirebaseFirestore.instance
            .collection('EQUIPE')
            .doc(equipe.id)
            .set(equipe.toJson());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Équipe ajoutée avec succès !"),
        ));

        _nomController.clear();
        setState(() {
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erreur lors de l'ajout de l'image."),
        ));
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de l\'équipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de l'ajout de l'équipe."),
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
        title: Text('Ajouter une Équipe'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom de l\'équipe'),
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
                    onPressed: _ajouterEquipe,
                    child: Text('Ajouter l\'équipe'),
                  ),
            SizedBox(height: 50),
            Divider(),
            Text('Liste des équipes'),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('EQUIPE').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: AppLoader());
                }

                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text('Erreur lors de la récupération des équipes.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucune équipe trouvée.'));
                }

                // Récupérer les équipes à partir des documents Firestore
                List<DocumentSnapshot> equipes = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: equipes.length,
                  itemBuilder: (context, index) {
                    var equipeDoc = equipes[index];

                    // Convertir le DocumentSnapshot en un objet Equipe
                    Equipe equipe = Equipe(
                      id: equipeDoc.id,
                      nom: equipeDoc['nom'],
                      logo: equipeDoc['logo'],
                      joueurs: [], // Si vous n'avez pas besoin de joueurs ici
                    );

                    return GestureDetector(
                      onTap: () {
                        changerPage(context, EditEquipePage(equipe: equipe));
                      },
                      child: ListTile(
                        leading: equipe.logo.isNotEmpty
                            ? SizedBox(
                          width: 50,
                          height: 50,
                          child: Image(
                            image: ResizeImage(
                              CachedNetworkImageProvider(equipe.logo),
                              width: 150,
                            ),
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(Icons.image_not_supported),
                        title: Text(equipe.nom),
                      ),
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
