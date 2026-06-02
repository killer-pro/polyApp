import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/drawer/compte/edit_infos_utilisateur.dart';
import 'package:new_app/pages/drawer/compte/edit_password.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:photo_view/photo_view.dart';

class CompteScreen extends StatelessWidget {
  CompteScreen({super.key});

  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Utilisateur?>(
          future: FirebaseAuth.instance.currentUser?.email != null
              ? _userService
                  .getUserByEmail(FirebaseAuth.instance.currentUser!.email!)
              : Future.value(null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: AppLoader());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Erreur lors de la récupération des données'));
            }
            final user = snapshot.data;
            if (user == null) {
              return Center(child: Text('Utilisateur introuvable'));
            }
            return _buildProfile(context, user);
          }),
    );
  }

  Widget _buildProfile(BuildContext context, Utilisateur user) {
    final avatarRadius = 55.0;
    final headerHeight = 160.0;

    return Stack(
      children: [
        // Scrollable content
        CustomScrollView(
          slivers: [
            // ── Header (cover + avatar + name) ──
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Cover gradient
                  Container(
                    height: headerHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          eptLightOrange,
                        ],
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
                        // Back button
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_new,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avatar overlapping the cover
                  Positioned(
                    top: headerHeight - avatarRadius,
                    child: GestureDetector(
                      onTap: () {
                        if (user.photo != null && user.photo!.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: PhotoView(
                                imageProvider:
                                    CachedNetworkImageProvider(user.photo!),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale:
                                    PhotoViewComputedScale.contained * 2.5,
                                backgroundDecoration:
                                    BoxDecoration(color: Colors.black),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundImage:
                              (user.photo != null && user.photo!.isNotEmpty)
                                  ? ResizeImage(
                                      CachedNetworkImageProvider(user.photo!),
                                      height: 220,
                                    )
                                  : null,
                          backgroundColor: grisClair,
                          child: (user.photo == null || user.photo!.isEmpty)
                              ? Icon(Icons.person, size: 54, color: eptDarkGrey)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Space below avatar ──
            SliverToBoxAdapter(child: SizedBox(height: avatarRadius + 16)),

            // ── Name + role ──
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Text(
                    '${user.prenom} ${user.nom.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Text(
                      user.role.toString().split('.').last,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Info card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        value: user.telephone ?? '—',
                        isFirst: true,
                      ),
                      _divider(),
                      _infoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      _divider(),
                      _infoTile(
                        icon: Icons.school_outlined,
                        label: 'Promo',
                        value: user.promo ?? '—',
                      ),
                      _divider(),
                      _infoTile(
                        icon: Icons.engineering_outlined,
                        label: 'Génie',
                        value: user.genie ?? '—',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Actions ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _actionButton(
                      icon: Icons.edit_outlined,
                      label: 'Modifier le profil',
                      onTap: () => changerPage(context, EditInfosUtilisateur()),
                    ),
                    SizedBox(height: 12),
                    _actionButton(
                      icon: Icons.lock_outline,
                      label: 'Modifier le mot de passe',
                      onTap: () => changerPage(context, EditPassword()),
                      outlined: true,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: eptLighterOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: eptDarkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Divider(height: 1, color: etpGrey),
      );

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: AppColors.primary),
              label: Text(label,
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: Colors.white),
              label: Text(label,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
    );
  }
}
