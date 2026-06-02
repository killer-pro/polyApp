import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/pages/interclasse/football/edit_delete_joueur.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'dart:io';
import '/models/equipe.dart';
import '/models/joueur.dart';
import 'package:new_app/models/enums/position_joueur.dart';

class EditEquipePage extends StatefulWidget {
  final Equipe equipe;

  EditEquipePage({required this.equipe});

  @override
  _EditEquipePageState createState() => _EditEquipePageState();
}

class _EditEquipePageState extends State<EditEquipePage> {
  final TextEditingController _nomController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  // Champs pour l'ajout des joueurs
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomJoueurController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomController.text = widget.equipe.nom;
  }

  // Fonction pour récupérer la liste des joueurs à partir du champ 'joueurs'
  List<Joueur> _getJoueursFromEquipe(DocumentSnapshot equipeSnapshot) {
    List<dynamic> joueursData = equipeSnapshot['joueurs'];
    return joueursData
        .map(
            (joueurData) => Joueur.fromJson(joueurData as Map<String, dynamic>))
        .toList();
  }

  // Fonction pour ajouter un joueur dans Firestore
  Future<void> _addJoueur(Joueur joueur) async {
    try {
      // Récupérer la liste actuelle des joueurs dans Firestore
      var snapshot = await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipe.id)
          .get();
      List<dynamic> joueursActuels = snapshot['joueurs'];

      // Ajouter le nouveau joueur
      joueursActuels.add(joueur.toJson());

      // Mettre à jour la liste des joueurs
      await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipe.id)
          .update({
        'joueurs': joueursActuels,
      });

      setState(() {
        _prenomController.clear();
        _nomJoueurController.clear();
        _positionController.clear();
      });

      debugPrint('Joueur ajouté avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout du joueur: $e');
    }
  }

  Future<void> _deleteEquipe() async {
    try {
      // Supprimer l'équipe de Firestore
      await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipe.id)
          .delete();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erreur lors de la suppression de l\'équipe : $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Voulez-vous vraiment supprimer cette équipe ?'),
                Text('Cette action est irréversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            ElevatedButton(
              child: Text('Supprimer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _deleteEquipe(); // Appel de la fonction de suppression
              },
            ),
          ],
        );
      },
    );
  }

  // Sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fonction pour uploader l'image dans Firebase Storage et obtenir l'URL
  Future<String?> _uploadImageToFirebase() async {
    if (_imageFile == null) return null;

    try {
      setState(() {
        _isLoading = true;
      });

      // Chemin de stockage dans Firebase Storage
      String fileName =
          'logos/${widget.equipe.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Obtenir l'URL de l'image uploadée
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _isLoading = false;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Erreur lors de l\'upload de l\'image: $e');
      return null;
    }
  }

  // Fonction pour mettre à jour l'équipe dans Firestore
  Future<void> _updateEquipe() async {
    String? imageUrl = await _uploadImageToFirebase();

    if (imageUrl != null) {
      // Mettre à jour le logo si une nouvelle image a été uploadée
      await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipe.id)
          .update({
        'nom': _nomController.text,
        'logo': imageUrl,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipe.id)
          .update({
        'nom': _nomController.text,
      });
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier une Équipe'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDeleteConfirmationDialog();
        },
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('EQUIPE')
            .doc(widget.equipe.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AppLoader());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Aucune équipe trouvée.'));
          }

          var equipeData = snapshot.data!;
          List<Joueur> joueurs = _getJoueursFromEquipe(equipeData);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom de l\'équipe'),
                ),
                SizedBox(height: 20),
                _imageFile == null
                    ? equipeData['logo'] != null
                        ? Image.network(equipeData['logo'], height: 150)
                        : Placeholder(fallbackHeight: 150)
                    : Image.file(_imageFile!, height: 150),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Modifier le logo'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateEquipe,
                  child: _isLoading
                      ? AppLoader()
                      : Text('Modifier l\'équipe'),
                ),
                SizedBox(height: 20),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Joueurs de l\'équipe',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddJoueurDialog(
                              onAddJoueur: (Joueur joueur) async {
                                await _addJoueur(joueur);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                joueurs.isEmpty
                    ? Text('Aucun joueur trouvé')
                    : Column(
                        children: joueurs
                            .map((joueur) => GestureDetector(
                                  onTap: () {
                                    changerPage(
                                        context,
                                        EditJoueurPage(
                                            joueur: joueur,
                                            equipeId: widget.equipe.id));
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.person),
                                    title:
                                        Text('${joueur.prenom} ${joueur.nom}'),
                                    subtitle: Text(
                                        'Poste: ${joueur.position?.name ?? ''} | Buts: ${joueur.totalBut}'),
                                  ),
                                ))
                            .toList(),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Boîte de dialogue pour ajouter un joueur
class AddJoueurDialog extends StatefulWidget {
  final Function(Joueur) onAddJoueur;

  AddJoueurDialog({required this.onAddJoueur});

  @override
  _AddJoueurDialogState createState() => _AddJoueurDialogState();
}

class _AddJoueurDialogState extends State<AddJoueurDialog> {
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomJoueurController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un joueur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _prenomController,
            decoration: InputDecoration(labelText: 'Prénom'),
          ),
          TextField(
            controller: _nomJoueurController,
            decoration: InputDecoration(labelText: 'Nom'),
          ),
          TextField(
            controller: _positionController,
            decoration: InputDecoration(labelText: 'Position'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            String prenom = _prenomController.text.trim();
            String nom = _nomJoueurController.text.trim();
            String position = _positionController.text.trim();

            if (prenom.isNotEmpty && nom.isNotEmpty && position.isNotEmpty) {
              Joueur joueur = Joueur(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                prenom: prenom,
                nom: nom,
                position: PositionJoueur.values.firstWhere(
                  (e) => e.name == position,
                  orElse: () => PositionJoueur.MILIEU,
                ),
                totalBut: 0,
              );
              widget.onAddJoueur(joueur);
            }
          },
          child: Text('Ajouter'),
        ),
      ],
    );
  }
}
