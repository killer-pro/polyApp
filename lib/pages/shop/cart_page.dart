import 'package:flutter/material.dart';
import 'package:new_app/services/cart_service.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cart = CartService.instance;
  final ShopService _shopService = ShopService();
  bool _loading = false;

  Future<void> _commander() async {
    if (_cart.items.value.isEmpty) return;
    setState(() => _loading = true);
    try {
      for (final item in _cart.items.value.values) {
        final code = await _shopService.postCommande(item.article, item.quantite);
        if (code != 'OK') throw Exception('Erreur pour ${item.article.titre}');
      }
      _cart.vider();
      if (mounted) {
        Navigator.pop(context);
        alerteMessageWidget(
            context, 'Commandes envoyées avec succès !', AppColors.success);
      }
    } catch (e) {
      if (mounted) {
        alerteMessageWidget(context, 'Erreur : $e', AppColors.echec);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon panier'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<Map<String, CartItem>>(
        valueListenable: _cart.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Votre panier est vide',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final itemList = items.values.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: itemList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = itemList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.article.image,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.article.titre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.article.prix} FCFA',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _QtyButton(
                                icon: Icons.remove,
                                onTap: () => _cart.changerQuantite(
                                    item.article.id, item.quantite - 1),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('${item.quantite}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _QtyButton(
                                icon: Icons.add,
                                onTap: () => _cart.changerQuantite(
                                    item.article.id, item.quantite + 1),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () =>
                                    _cart.retirer(item.article.id),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _CartSummary(
                total: _cart.total,
                loading: _loading,
                onCommander: _commander,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int total;
  final bool loading;
  final VoidCallback onCommander;
  const _CartSummary(
      {required this.total,
      required this.loading,
      required this.onCommander});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text('$total FCFA',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: orange)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onCommander,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Commander',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
