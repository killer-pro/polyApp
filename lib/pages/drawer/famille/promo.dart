import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/promo.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
class PromotionPage extends StatefulWidget {
  final String nomPromo;
  PromotionPage(this.nomPromo, {Key? key}) : super(key: key);

  @override
  _PromotionPageState createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<Utilisateur> _utilisateurs = [];
  List<Utilisateur> _filteredUtilisateurs = [];
  Promo? _promo;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterUtilisateurs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final utilisateurs = await _userService.getAllUserInPromo(widget.nomPromo);
    final promo = await _userService.getListByName(widget.nomPromo);
    setState(() {
      _utilisateurs = utilisateurs;
      _filteredUtilisateurs = _utilisateurs;
      _promo = promo;
    });
  }

  void _filterUtilisateurs() {
    final query = _searchController.text.toLowerCase();
    _filteredUtilisateurs = _utilisateurs.where((utilisateur) {
      final fullName = '${utilisateur.prenom} ${utilisateur.nom}'.toLowerCase();
      final genie = utilisateur.genie?.toLowerCase() ?? '';
      final telephone = utilisateur.telephone ?? '';

      return fullName.contains(query) ||
          genie.contains(query) ||
          telephone.contains(query);
    }).toList();
    setState(() {}); // Trigger rebuild only for filtered list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              _buildPromoHeader(),
              SizedBox(height: 20),
              _buildSearchBar(),
              SizedBox(height: 20),
              _buildUserList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoHeader() {
    if (_promo == null) {
      return AppLoader();
    }
    return Center(
      child: Column(
        children: [
          Image(
            image: ResizeImage(
              CachedNetworkImageProvider(_promo!.logo),
              width: 450,  // Largeur souhaitée
              height: 450,  // Hauteur souhaitée
            ),
            height: 150,  // Taille d'affichage
          ),
          SizedBox(height: 10),
          Text(
            'Promotion ${_promo!.nom}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Devise: "${_promo!.devise}"',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Center(
      child: SizedBox(
        height: 30,
        width: 250,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'chercher',
            hintStyle: TextStyle(fontSize: 12, fontFamily: 'InterMedium'),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (_filteredUtilisateurs.isEmpty) {
      return Text("Aucun utilisateur trouvé");
    }

    return Column(
      children: _filteredUtilisateurs.map((utilisateur) {
        return eleveWidget(
          utilisateur.photo,
          "${utilisateur.prenom} ${utilisateur.nom.toUpperCase()}",
          utilisateur.genie ?? 'Aucun génie spécifié',
          utilisateur.telephone ?? 'Numéro non disponible',
          context,
        );
      }).toList(),
    );
  }
}

Widget eleveWidget(String? photoUrl, String nom, String genie, String numero,BuildContext context) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 5),
    elevation: 0,
    color: eptLighterOrange,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    child: ListTile(
      leading: GestureDetector(
        onTap: () {
          if (photoUrl != null && photoUrl.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(photoUrl),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 2.5,
                  backgroundDecoration: BoxDecoration(color: Colors.black),
                ),
              ),
            );
          }
        },
        child: CircleAvatar(
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? CachedNetworkImageProvider(photoUrl)
              : null,
          child: photoUrl == null || photoUrl.isEmpty ? Icon(Icons.person) : null,
          radius: 30,
        ),
      ),
      title: Text(
        nom,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(genie),
          Row(
            children: [
              Icon(Icons.phone, size: 14),
              SizedBox(width: 5),
              Text(numero),
            ],
          ),
        ],
      ),
    ),
  );
}