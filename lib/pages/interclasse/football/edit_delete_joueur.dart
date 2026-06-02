import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/joueur.dart';
import 'package:new_app/models/enums/position_joueur.dart';

class EditJoueurPage extends StatefulWidget {
  final Joueur joueur;
  final String equipeId; // L'ID de l'équipe à laquelle le joueur appartient

  EditJoueurPage({required this.joueur, required this.equipeId});

  @override
  _EditJoueurPageState createState() => _EditJoueurPageState();
}

class _EditJoueurPageState extends State<EditJoueurPage> {
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _totalButController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prenomController.text = widget.joueur.prenom;
    _nomController.text = widget.joueur.nom;
    _positionController.text = widget.joueur.position?.name ?? '';
    _totalButController.text = widget.joueur.totalBut.toString();
  }

  // Fonction pour mettre à jour les informations du joueur dans Firestore
  Future<void> _updateJoueur() async {
    try {
      await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipeId)
          .update({
        'joueurs': FieldValue.arrayRemove(
            [widget.joueur.toJson()]) // Supprimer l'ancien joueur
      });

      Joueur updatedJoueur = Joueur(
        id: widget.joueur.id,
        prenom: _prenomController.text,
        nom: _nomController.text,
        position: PositionJoueur.values.firstWhere(
          (e) => e.name == _positionController.text,
          orElse: () => PositionJoueur.MILIEU,
        ),
        totalBut: int.parse(_totalButController.text),
      );

      await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipeId)
          .update({
        'joueurs': FieldValue.arrayUnion([updatedJoueur.toJson()])
      });

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du joueur : $e');
    }
  }

  Future<void> _deleteJoueur() async {
    try {
      await FirebaseFirestore.instance
          .collection('EQUIPE')
          .doc(widget.equipeId)
          .update({
        'joueurs': FieldValue.arrayRemove([widget.joueur.toJson()])
      });

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erreur lors de la suppression du joueur : $e');
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
                Text('Voulez-vous vraiment supprimer ce joueur ?'),
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
                _deleteJoueur(); // Appel de la fonction de suppression
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Joueur'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _showDeleteConfirmationDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _totalButController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total des Buts'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed:
                  _updateJoueur, // Mettre à jour les informations du joueur
              child: Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }
}
