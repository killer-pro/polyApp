import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/membre.dart';
import 'package:new_app/models/enums/sport_type.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/reusable_description_input.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class CreateMemberPage extends StatefulWidget {
  final String sport;
  const CreateMemberPage({required this.sport, Key? key}) : super(key: key);

  State<CreateMemberPage> createState() => _CreateMemberState();
}

class _CreateMemberState extends State<CreateMemberPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<String> _url = ValueNotifier("");

  final SportService _sportService = SportService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Créer un membre"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _url,
                builder: (context, url, child) {
                  return Container(
                    height: MediaQuery.of(context).size.width * 0.6,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(10)),
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
                                            String? url =
                                                await _userService.uploadImage(
                                                    context, _loading, _url);
                                            if (url != null) {
                                              alerteMessageWidget(
                                                  context,
                                                  "Fichier enregistré avec succès !",
                                                  AppColors.success);
                                            } else {
                                              alerteMessageWidget(
                                                  context,
                                                  "Une erreur s'est produit lors du chargement !",
                                                  AppColors.echec);
                                            }
                                          },
                                          icon: Icon(Icons.library_add),
                                          label: Text("Importer",
                                              style: TextStyle(
                                                  color: AppColors.black)),
                                        );
                                }),
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
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
              SubmittedButton("Créer", () async {
                if (_nameController.text.isNotEmpty && _url.value.isNotEmpty) {
                  Membre newMembre = Membre(
                    nom: _nameController.text,
                    image: _url.value,
                    role: _roleController.text,
                    sport: SportType.values.firstWhere(
                      (e) => e.name == widget.sport,
                      orElse: () => SportType.FOOTBALL,
                    ),
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                  );
                  await _sportService.ajouterMembre(newMembre);
                  alerteMessageWidget(
                      context, "Membre créé avec succès !", AppColors.success);
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
