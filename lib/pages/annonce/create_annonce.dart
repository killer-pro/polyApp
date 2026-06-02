// ignore_for_file: must_be_immutable, use_build_context_synchronously, body_might_complete_normally_nullable

import 'dart:io';
import 'package:intl/intl.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/annonce.dart';
import 'package:new_app/models/basket.dart';
import 'package:new_app/models/categorie.dart';
import 'package:new_app/models/enums/sport_type.dart';
import 'package:new_app/models/equipe.dart';
import 'package:new_app/models/football.dart';
import 'package:new_app/models/jeux_esprit.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/models/volleyball.dart';
import 'package:new_app/pages/annonce/annonce_screen.dart';
import 'package:new_app/pages/interclasse/football/home_admin_sport_type_page.dart';
import 'package:new_app/services/annonce_service.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/reusable_description_input.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class CreateAnnonce extends StatelessWidget {
  CreateAnnonce({super.key});
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _titreTextController = TextEditingController();
  final TextEditingController _lieuTextController = TextEditingController();
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    DateTime.now().minute,
  );
  final UserService _userService = UserService();
  final AnnonceService _annonceService = AnnonceService();

  final ValueNotifier<List<Categorie>> _categories = ValueNotifier([]);
  final ValueNotifier<Categorie?> _selectedCategory = ValueNotifier(null);
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<String> _url = ValueNotifier("");
  final ValueNotifier<bool> _docLoading = ValueNotifier(false);
  final ValueNotifier<String?> _communiqueUrl = ValueNotifier(null);

  Future<void> _loadCategories() async {
    List<Categorie> categories = await _annonceService.getAllCategories();
    _categories.value = categories;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // Sélectionner la date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Sélectionner l'heure après la date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate.value),
      );

      if (pickedTime != null) {
        // Combiner la date et l'heure
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Mettre à jour la variable avec la nouvelle date et heure sélectionnées
        _selectedDate.value = pickedDateTime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadCategories();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Créer une annonce"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.02, 20, 0),
            child: Column(
              children: <Widget>[
                ValueListenableBuilder<String>(
                    valueListenable: _url,
                    builder: (context, url, child) {
                      return url == ""
                          ? Container(
                              height: MediaQuery.sizeOf(context).width * 0.6,
                              width: MediaQuery.sizeOf(context).width * 0.5,
                              decoration: BoxDecoration(
                                  color: AppColors.gray,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: ValueListenableBuilder<bool>(
                                    valueListenable: _loading,
                                    builder: (context, loading, child) {
                                      return loading
                                          ? AppLoader()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                    child: ElevatedButton.icon(
                                                  style: ButtonStyle(
                                                      iconColor:
                                                          WidgetStateProperty
                                                              .all(AppColors
                                                                  .black)),
                                                  onPressed: () async {
                                                    String? url =
                                                        await _userService
                                                            .uploadImage(
                                                                context,
                                                                _loading,
                                                                _url);
                                                    if (url != "") {
                                                      alerteMessageWidget(
                                                          context,
                                                          "Fichier enregistré avec succès !",
                                                          AppColors.success);
                                                    } else {
                                                      alerteMessageWidget(
                                                          context,
                                                          "Echec de l'importation du fichier !",
                                                          AppColors.echec);
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.library_add,
                                                    color: AppColors.black,
                                                  ),
                                                  label: Text(
                                                    "Importer",
                                                    style: TextStyle(
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                )),
                                              ],
                                            );
                                    }),
                              ),
                            )
                          : Image.network(url);
                    }),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder<List<Categorie>>(
                      valueListenable: _categories,
                      builder: (context, categories, child) {
                        return ValueListenableBuilder<Categorie?>(
                          valueListenable: _selectedCategory,
                          builder: (context, selectedCategory, child) {
                            return DropdownButton<Categorie>(
                              hint: Text('Catégorie'),
                              value: categories.contains(selectedCategory)
                                  ? selectedCategory
                                  : null,
                              onChanged: (Categorie? newValue) {
                                _selectedCategory.value = newValue;
                              },
                              items: categories
                                  .map<DropdownMenuItem<Categorie>>(
                                      (Categorie categorie) {
                                return DropdownMenuItem<Categorie>(
                                  value: categorie,
                                  child: Text(categorie.libelle),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    )),
                SizedBox(
                  height: 20,
                ),
                reusableTextFormField("Titre", _titreTextController, (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez rentrer un titre";
                  }
                  return null;
                }),
                SizedBox(
                  height: 20,
                ),
                reusableTextFormField("Lieu", _lieuTextController, (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez rentrer un lieu";
                  }
                  return null;
                }),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () => _selectDateTime(context),
                  child: Row(children: [
                    Icon(Icons.calendar_month),
                    SizedBox(
                      width: 5,
                    ),
                    ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDate,
                        builder: (context, selectedDate, child) {
                          return Text(
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(_selectedDate.value),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        }),
                  ]),
                ),
                SizedBox(
                  height: 20,
                ),
                ReusableDescriptionInput(
                    "Description", _descriptionTextController, (value) {
                  return null;
                }),
                SizedBox(height: 20),
                // Communiqué optionnel (PDF, docx, xlsx)
                ValueListenableBuilder<bool>(
                  valueListenable: _docLoading,
                  builder: (context, loading, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: _communiqueUrl,
                      builder: (context, docUrl, _) {
                        return Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: loading
                                  ? null
                                  : () async {
                                      final url =
                                          await _userService.uploadDocument(
                                              _docLoading);
                                      if (url != null) {
                                        _communiqueUrl.value = url;
                                        alerteMessageWidget(
                                            context,
                                            "Communiqué joint avec succès !",
                                            AppColors.success);
                                      } else {
                                        alerteMessageWidget(
                                            context,
                                            "Erreur lors de l'import du communiqué.",
                                            AppColors.echec);
                                      }
                                    },
                              icon: loading
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Icon(Icons.attach_file),
                              label: Text(docUrl == null
                                  ? "Joindre un communiqué"
                                  : "Changer le communiqué"),
                            ),
                            if (docUrl != null) ...[
                              SizedBox(width: 8),
                              Icon(Icons.check_circle,
                                  color: AppColors.success, size: 20),
                            ]
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
                SubmittedButton(
                  "Poster",
                  () async {
                    if (_titreTextController.text.isEmpty) {
                      alerteMessageWidget(context, "Le titre est obligatoire.",
                          AppColors.echec);
                    } else if (_lieuTextController.text.isEmpty) {
                      alerteMessageWidget(
                          context, "Le lieu est obligatoire.", AppColors.echec);
                    } else if (_url.value.isEmpty) {
                      alerteMessageWidget(
                          context,
                          "Vous devez sélectionner une image.",
                          AppColors.echec);
                    } else {
                      Annonce annonce = Annonce(
                          categorie: _selectedCategory.value == null
                              ? Categorie(id: '', libelle: '', logo: '')
                              : _selectedCategory.value!,
                          titre: _titreTextController.text,
                          date: _selectedDate.value,
                          dateCreation: DateTime.now(),
                          description: _descriptionTextController.text,
                          lieu: _lieuTextController.text,
                          likes: 0,
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          comments: [],
                          image: _url.value,
                          partageLien: "",
                          communiqueUrl: _communiqueUrl.value);

                      try {
                        String code =
                            await _annonceService.postAnnonce(annonce);
                        if (code == "OK") {
                          alerteMessageWidget(context,
                              "Annonce créée avec succès !", AppColors.success);
                          changerPage(context, AnnonceScreen());
                        }
                      } catch (e) {
                        alerteMessageWidget(
                            context,
                            "Une erreur est survenue lors de la création. $e",
                            AppColors.echec);
                      }
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
