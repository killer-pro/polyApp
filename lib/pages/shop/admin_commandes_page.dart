import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/commande.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';

class AdminCommandesPage extends StatefulWidget {
  const AdminCommandesPage({super.key});

  @override
  State<AdminCommandesPage> createState() => _AdminCommandesPageState();
}

class _AdminCommandesPageState extends State<AdminCommandesPage> {
  final ShopService _shopService = ShopService();
  final _articleCollection =
      FirebaseFirestore.instance.collection('ARTICLE');
  final _userCollection = FirebaseFirestore.instance.collection('USER');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des commandes'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ArticleShop>>(
        future: _shopService.getAllArticle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoader());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun produit.'));
          }
          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: articles.length,
            itemBuilder: (context, index) =>
                _ArticleCommandesTile(
                    article: articles[index],
                    shopService: _shopService,
                    userCollection: _userCollection),
          );
        },
      ),
    );
  }
}

class _ArticleCommandesTile extends StatefulWidget {
  final ArticleShop article;
  final ShopService shopService;
  final CollectionReference userCollection;

  const _ArticleCommandesTile({
    required this.article,
    required this.shopService,
    required this.userCollection,
  });

  @override
  State<_ArticleCommandesTile> createState() => _ArticleCommandesTileState();
}

class _ArticleCommandesTileState extends State<_ArticleCommandesTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.article.image,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            title: Text(widget.article.titre,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${widget.article.prix} FCFA'),
            trailing: IconButton(
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: orange,
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded)
            StreamBuilder<QuerySnapshot>(
              stream: widget.shopService
                  .getCommandesByArticle(widget.article.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Aucune commande pour ce produit.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                final commandes = snapshot.data!.docs
                    .map((d) =>
                        Commande.fromJson(d.data() as Map<String, dynamic>))
                    .toList();

                return Column(
                  children: [
                    const Divider(height: 1),
                    ...commandes.map((c) => _CommandeRow(
                          commande: c,
                          shopService: widget.shopService,
                          userCollection: widget.userCollection,
                          articlePrix: widget.article.prix,
                        )),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CommandeRow extends StatelessWidget {
  final Commande commande;
  final ShopService shopService;
  final CollectionReference userCollection;
  final int articlePrix;

  const _CommandeRow({
    required this.commande,
    required this.shopService,
    required this.userCollection,
    required this.articlePrix,
  });

  Future<String> _getUserName() async {
    try {
      final doc = await userCollection.doc(commande.userId).get();
      if (!doc.exists) return commande.userId;
      final data = doc.data() as Map<String, dynamic>;
      return '${data['prenom'] ?? ''} ${(data['nom'] ?? '').toString().toUpperCase()}'.trim();
    } catch (_) {
      return commande.userId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        final nom = snapshot.data ?? '…';
        final total = articlePrix * commande.nombre;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      'Qté : ${commande.nombre}  •  $total FCFA',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              _StatusToggle(
                label: 'Reçu',
                value: commande.recu,
                color: Colors.blue,
                onChanged: (v) =>
                    shopService.updateCommandeFields(commande.id, recu: v),
              ),
              const SizedBox(width: 8),
              _StatusToggle(
                label: 'Payé',
                value: commande.paye,
                color: Colors.green,
                onChanged: (v) =>
                    shopService.updateCommandeFields(commande.id, paye: v),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _StatusToggle({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: value ? color.withAlpha(30) : Colors.grey[100],
          border: Border.all(color: value ? color : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 14,
              color: value ? color : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: value ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
