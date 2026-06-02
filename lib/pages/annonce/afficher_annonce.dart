import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/annonce.dart';
import 'package:new_app/pages/annonce/annonce_screen.dart';
import 'package:new_app/pages/annonce/edit_annonce.dart';
import 'package:new_app/services/annonce_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_text_formatter/whatsapp_text_formatter.dart';

Future<void> _onOpenLink(LinkableElement link) async {
  final Uri url = Uri.parse(link.url);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch ${link.url}';
  }
}

class AfficherAnononceScreen extends StatefulWidget {
  final Annonce annonce;

  const AfficherAnononceScreen({required this.annonce, super.key});

  @override
  State<AfficherAnononceScreen> createState() => _AfficherAnononceScreenState();
}

class _AfficherAnononceScreenState extends State<AfficherAnononceScreen> {
  bool isAdmin = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final String? role = await _userService.getUserRole(user.email!);
      if (mounted && (role == 'ADMIN_MB' || role == 'ADMIN')) {
        setState(() => isAdmin = true);
      }
    } catch (e) {
      debugPrint("Erreur lors de la vérification du rôle : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.annonce;
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true),
      extendBodyBehindAppBar: true,
      floatingActionButton: isAdmin
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "editButton",
                  onPressed: () =>
                      changerPage(context, EditAnnonce(idAnnonce: a.id)),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.edit),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: "deleteButton",
                  onPressed: () => _showDeleteConfirmation(context, a.id),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete),
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---- Image hero ----
            Stack(
              children: [
                Container(
                  height: 470,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/polytech-Info/white_bg_ept.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImage(imageUrl: a.image),
                          ),
                        ),
                        child: SizedBox(
                          height: 370,
                          child: Image(
                            image: ResizeImage(
                              CachedNetworkImageProvider(a.image),
                              height: 1110,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            Container(height: 10, color: jauneClair),

            // ---- Titre + lieu ----
            Container(
              color: orange,
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Text(
                    a.titre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    a.lieu,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Container(height: 10, color: jauneClair),
            const SizedBox(height: 20),

            // ---- Détails ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${simpleDateformat(a.date)} à ${getHour(a.date)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // ---- Description ----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 251, 240, 223),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: WhatsAppTextFormatter(
                      text: a.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  // ---- Communiqué ----
                  if (a.communiqueUrl != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(a.communiqueUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        icon:
                            const Icon(Icons.picture_as_pdf, color: Colors.red),
                        label: const Text('Voir le communiqué'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],

                  // ---- Likes ----
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.favorite_outline,
                          color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text('${a.likes} j\'aime',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content:
            const Text('Êtes-vous sûr de vouloir supprimer cette annonce ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => _deleteAnnonce(id, context),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnonce(String id, BuildContext context) async {
    try {
      await AnnonceService().deleteAnnonceById(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce supprimée avec succès')),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      changerPage(context, AnnonceScreen());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la suppression de l\'annonce : $e')),
      );
    }
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained * 1,
            maxScale: PhotoViewComputedScale.covered * 5,
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
