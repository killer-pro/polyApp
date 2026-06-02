import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';

/// Loader custom aux couleurs de l'app.
///
/// Utilisations :
/// ```dart
/// // Centré (dans un FutureBuilder, etc.)
/// return const AppLoader();
///
/// // Avec message
/// return const AppLoader(message: 'Chargement...');
///
/// // Overlay plein écran (ex: pendant une action async)
/// AppLoader.overlay(context);   // afficher
/// Navigator.pop(context);       // fermer
/// ```
class AppLoader extends StatefulWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  /// Affiche un overlay plein écran non-dismissible.
  static void overlay(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => PopScope(
        canPop: false,
        child: Center(child: AppLoader(message: message)),
      ),
    );
  }

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer spinning arc
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Inner pulsing icon
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: eptLighterOrange,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/homepage/bde_ept.jpg',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
