import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/promo.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/drawer/famille/promo.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';

class FamillePolytechnicienneScreen extends StatefulWidget {
  FamillePolytechnicienneScreen({Key? key}) : super(key: key);

  @override
  _FamillePolytechnicienneScreenState createState() =>
      _FamillePolytechnicienneScreenState();
}

class _FamillePolytechnicienneScreenState
    extends State<FamillePolytechnicienneScreen> {
  UserService _userService = UserService();
  TextEditingController _searchController = TextEditingController();
  List<Promo> _promos = [];
  List<Promo> _filteredPromos = [];

  @override
  void initState() {
    super.initState();
    _loadPromos();
    _searchController.addListener(_filterPromos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<int> getTailleListe(String nom) async {
    List<Utilisateur> maListe = await _userService.getAllUserInPromo(nom);
    return maListe.length;
  }

  Future<void> _loadPromos() async {
    final promos = await _userService.getListPromo();
    setState(() {
      _promos = promos;
      _filteredPromos = _promos;
    });
  }

  void _filterPromos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPromos = _promos.where((promo) {
        return promo.nom.toLowerCase().contains(query) ||
            promo.devise.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Gradient header ──
          _buildHeader(context),

          // ── Search bar ──
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une promo...',
                hintStyle: TextStyle(fontSize: 14, color: eptDarkGrey),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: eptLighterOrange,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          // ── Promo count label ──
          Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Text(
                  '${_filteredPromos.length} promotion${_filteredPromos.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: eptDarkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: _filteredPromos.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredPromos.length,
                    itemBuilder: (context, index) {
                      final promo = _filteredPromos.reversed.toList()[index];
                      return _promoCard(promo);
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: eptDarkGrey),
                        SizedBox(height: 12),
                        Text(
                          'Aucun résultat trouvé',
                          style: TextStyle(color: eptDarkGrey, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, eptLighterOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Famille Polytechnicienne',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Toutes les promotions',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Balance the back button
                  SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoCard(Promo promo) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => changerPage(context, PromotionPage(promo.nom)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                // Logo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: ResizeImage(
                      CachedNetworkImageProvider(promo.logo),
                      width: 128,
                    ),
                    backgroundColor: eptLighterOrange,
                  ),
                ),
                SizedBox(width: 14),

                // Name + devise
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.nom,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        promo.devise,
                        style: TextStyle(
                          fontSize: 12,
                          color: eptDarkGrey,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),

                // Member count badge
                FutureBuilder<int>(
                  future: getTailleListe(promo.nom),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? '${snapshot.data}' : '—';
                    return Column(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: eptLighterOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                count,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Icon(Icons.chevron_right, color: eptDarkGrey, size: 18),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
