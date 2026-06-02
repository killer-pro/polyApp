// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/categorie_shop.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/reusable_description_input.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class CreateArticleShop extends StatelessWidget {
  CreateArticleShop({super.key});
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    DateTime.now().minute,
  );
  final ShopService _shopService = ShopService();
  final UserService _userService = UserService();

  final ValueNotifier<List<Collection>> _collections = ValueNotifier([]);
  final ValueNotifier<List<CategorieShop>> _categories = ValueNotifier([]);

  final ValueNotifier<Collection?> _selectedcollectionA = ValueNotifier(null);
  final ValueNotifier<CategorieShop?> _selectedCategorieShop =
      ValueNotifier(null);

  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<String> _url = ValueNotifier("");

  Future<void> _loadcollections() async {
    List<Collection> collections = await _shopService.getAllCollection();
    _collections.value = collections;
    List<CategorieShop> categories = await _shopService.getAllCategorieShop();
    _categories.value = categories;
  }

/*  Future<void> _selectDateTime(BuildContext context) async {
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
        initialTime:
            TimeOfDay.fromDateTime(_selectedDate.value ?? DateTime.now()),
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
  }*/

  @override
  Widget build(BuildContext context) {
    _loadcollections();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Créer un article"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
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
                ValueListenableBuilder<List<CategorieShop>>(
                  valueListenable: _categories,
                  builder: (context, categories, child) {
                    return ValueListenableBuilder<CategorieShop?>(
                      valueListenable: _selectedCategorieShop,
                      builder: (context, selectedCategorieShop, child) {
                        return DropdownButton<CategorieShop>(
                          hint: Text('catégorie'),
                          value: categories.contains(selectedCategorieShop)
                              ? selectedCategorieShop
                              : null,
                          onChanged: (CategorieShop? newValue) {
                            _selectedCategorieShop.value = newValue;
                          },
                          items: categories
                              .map<DropdownMenuItem<CategorieShop>>(
                                  (CategorieShop collection) {
                            return DropdownMenuItem<CategorieShop>(
                              value: collection,
                              child: Text(collection.libelle),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                reusableTextFormField("Nom", _titreController, (value) {
                  return null;
                }),
                SizedBox(
                  height: 20,
                ),
                reusableTextFormField("Prix", _prixController, (value) {
                  return null;
                }),
                SizedBox(
                  height: 20,
                ),
                ReusableDescriptionInput(
                    "Description", _descriptionTextController, (value) {
                  return null;
                }),
                SizedBox(
                  height: 20,
                ),
                SubmittedButton("Poster", () async {
                  ArticleShop articleShop = ArticleShop(
                    prix: int.parse(_prixController.value.text),
                    id: DateTime.now().toString(),
                    dateCreation: DateTime.now(),
                    description: _descriptionTextController.value.text,
                    titre: _titreController.value.text,
                    image: _url.value,
                    categorie: _selectedCategorieShop.value!,
                    commandes: [],
                    partageLien: "",
                  );
                  try {
                    try {
                      String code =
                          await _shopService.postArticleShop(articleShop);
                      if (code == "OK") {
                        Navigator.of(context).pop();
                        alerteMessageWidget(context,
                            "Article crée avec succès !", AppColors.success);
                      }
                    } catch (e) {
                      return null;
                    }
                  } catch (e) {
                    alerteMessageWidget(
                        context,
                        "Une erreur est survie lors de la création.$e",
                        AppColors.echec);
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
