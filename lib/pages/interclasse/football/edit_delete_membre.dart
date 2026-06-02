import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/membre.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class EditMemberPage extends StatefulWidget {
  final Membre membre;
  const EditMemberPage({required this.membre, Key? key}) : super(key: key);

  State<EditMemberPage> createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMemberPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<String> _url = ValueNotifier("");

  final SportService _sportService = SportService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.membre.nom;
    _roleController.text = widget.membre.role;
    _url.value = widget.membre.image;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("Êtes-vous sûr de vouloir supprimer ce membre ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                await _sportService.supprimerMembre(widget.membre.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Membre supprimé avec succès !"),
                  ),
                );
              },
              child: Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return; // Pas d'image choisie
    }

    String filename = pickedImage.name;
    File imageFile = File(pickedImage.path);

    Reference reference = FirebaseStorage.instance.ref(filename);

    try {
      _loading.value = true;
      await reference.putFile(imageFile);
      _url.value = await reference.getDownloadURL();
      _loading.value = false;
    } catch (error) {
      _loading.value = false;
      alerteMessageWidget(context,
          "Une erreur s'est produite lors du chargement !", AppColors.echec);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Modifier un membre"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _confirmDelete(context);
        },
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _url,
                builder: (context, url, child) {
                  return GestureDetector(
                    onTap: () async {
                      await _uploadImage();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.6,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: url.isEmpty
                          ? Center(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _loading,
                                builder: (context, loading, child) {
                                  return loading
                                      ? AppLoader()
                                      : ElevatedButton.icon(
                                          style: ButtonStyle(
                                              iconColor:
                                                  WidgetStateProperty.all(
                                                      AppColors.black)),
                                          onPressed: () async {
                                            await _uploadImage();
                                          },
                                          icon: Icon(Icons.library_add),
                                          label: Text("Importer",
                                              style: TextStyle(
                                                  color: AppColors.black)),
                                        );
                                },
                              ),
                            )
                          : Image.network(
                              url,
                              fit: BoxFit.cover,
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Rôle'),
              ),
              SizedBox(height: 20),
              SubmittedButton("Modifier", () async {
                if (_nameController.text.isNotEmpty && _url.value.isNotEmpty) {
                  Membre updatedMembre = Membre(
                    nom: _nameController.text,
                    image: _url.value,
                    role: _roleController.text,
                    sport: widget.membre.sport,
                    id: widget.membre.id,
                  );
                  await _sportService.modifierMembre(updatedMembre);
                  alerteMessageWidget(context, "Membre modifié avec succès !",
                      AppColors.success);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  alerteMessageWidget(context,
                      "Veuillez remplir tous les champs !", AppColors.echec);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
