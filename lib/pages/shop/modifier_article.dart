import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/categorie_shop.dart';
import 'package:new_app/pages/shop/gestion_article.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/reusable_description_input.dart';
import 'package:new_app/widgets/reusable_widgets.dart';
import 'package:new_app/widgets/submited_button.dart';

class EditArticleShop extends StatefulWidget {
  final ArticleShop article;
  EditArticleShop({required this.article});

  @override
  _EditArticleShopState createState() => _EditArticleShopState();
}

class _EditArticleShopState extends State<EditArticleShop> {
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final ShopService _shopService = ShopService();

  final ValueNotifier<CategorieShop?> _selectedCategorieShop =
      ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<String> _url = ValueNotifier("");

  List<CategorieShop> _categories = [];
  final ImagePicker _picker = ImagePicker();
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _descriptionTextController.text = widget.article.description;
    _titreController.text = widget.article.titre;
    _prixController.text = widget.article.prix.toString();
    _selectedCategorieShop.value = widget.article.categorie;
    _selectedDate.value = widget.article.dateCreation;
    _url.value = widget.article.image;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categories = await _shopService.getAllCategorieShop();
    setState(() {});
  }

  // Affichage de la boîte de dialogue de confirmation de suppression
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("Êtes-vous sûr de vouloir supprimer cet article ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Supprimer"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteArticle();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteArticle() async {
    try {
      await _shopService.deleteArticle(widget.article.id, _url.value);

      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ArticleListPage()),
      );
      alerteMessageWidget(
        context,
        "Article supprimé avec succès !",
        AppColors.success,
      );
    } catch (e) {
      Navigator.of(context).pop();

      alerteMessageWidget(
        context,
        "Erreur lors de la suppression : $e",
        AppColors.echec,
      );
    }
  }

  Future<void> _selectAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });

      try {
        // Essayer de supprimer l'ancienne image si elle existe
        if (_url.value.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(_url.value).delete();
          } catch (e) {
            print("L'image n'existe pas dans le stockage : $e");
          }
        }

        // Télécharger la nouvelle image
        String newFileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
            FirebaseStorage.instance.ref().child('articles/$newFileName.jpg');
        await storageRef.putFile(_newImage!);

        String newImageUrl = await storageRef.getDownloadURL();

        setState(() {
          _url.value = newImageUrl;
        });

        // Mettre à jour l'image dans Firestore
        await _shopService.updateArticleImage(widget.article.id, newImageUrl);

        alerteMessageWidget(
            context, "Image modifiée avec succès !", AppColors.success);
      } catch (e) {
        alerteMessageWidget(
            context, "Erreur lors de la modification : $e", AppColors.echec);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Modifier l'article"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDeleteConfirmationDialog(context);
        },
        backgroundColor: AppColors.echec,
        child: Icon(Icons.delete),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ValueListenableBuilder<String>(
              valueListenable: _url,
              builder: (context, url, child) {
                return Column(
                  children: [
                    _newImage != null
                        ? Image.file(_newImage!)
                        : (url.isNotEmpty
                            ? Image.network(url)
                            : Container(
                                height: 200,
                                width: double.infinity,
                                color: AppColors.gray,
                                child: Center(child: Text("Pas d'image")),
                              )),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _selectAndUploadImage,
                      icon: Icon(Icons.image),
                      label: Text("Modifier l'image"),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            reusableTextFormField("Titre", _titreController, (value) {
              return null;
            }),
            SizedBox(height: 20),
            reusableTextFormField("Prix", _prixController, (value) {
              return null;
            }),
            SizedBox(height: 20),
            ValueListenableBuilder<CategorieShop?>(
              valueListenable: _selectedCategorieShop,
              builder: (context, selectedCategorie, child) {
                return DropdownButtonFormField<CategorieShop>(
                  initialValue: _categories.firstWhere(
                    (categorie) => categorie.id == selectedCategorie?.id,
                    orElse: () => CategorieShop(id: '', libelle: ''),
                  ),
                  hint: Text("Sélectionnez une catégorie"),
                  items: _categories.map((CategorieShop categorie) {
                    return DropdownMenuItem<CategorieShop>(
                      value: categorie,
                      child: Text(categorie.libelle),
                    );
                  }).toList(),
                  onChanged: (CategorieShop? newCategorie) {
                    _selectedCategorieShop.value = newCategorie;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Catégorie',
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ReusableDescriptionInput("Description", _descriptionTextController,
                (value) {
              return null;
            }),
            SizedBox(height: 20),
            SubmittedButton("Modifier l'article", () async {
              ArticleShop updatedArticle = ArticleShop(
                id: widget.article.id,
                dateCreation: _selectedDate.value!,
                description: _descriptionTextController.text,
                titre: _titreController.text,
                prix: int.parse(_prixController.text),
                image: _url.value,
                categorie: _selectedCategorieShop.value!,
                commandes: widget.article.commandes,
                partageLien: widget.article.partageLien,
              );

              try {
                String result =
                    await _shopService.updateArticleShop(updatedArticle);
                if (result == "OK") {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ArticleListPage()),
                  );
                  alerteMessageWidget(context, "Article modifié avec succès !",
                      AppColors.success);
                }
              } catch (e) {
                alerteMessageWidget(context,
                    "Erreur lors de la modification : $e", AppColors.echec);
              }
            }),
          ],
        ),
      ),
    );
  }
}
