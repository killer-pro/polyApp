import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/pages/annonce/annonce_screen.dart';
import 'package:new_app/pages/object_perdus/objets_perdus.dart';
import 'package:new_app/pages/home/home_page.dart';
import 'package:new_app/pages/shop/shop_screen.dart';
import 'package:new_app/pages/interclasse/interclasse.dart';
import 'package:new_app/pages/drawer/xoss/xoss_screen.dart';
import 'package:new_app/utils/app_colors.dart';

class navbar extends StatefulWidget {
  const navbar({super.key, required this.pageIndex});
  final int pageIndex;
  @override
  State<navbar> createState() => _navbarState();
}

class _navbarState extends State<navbar> {
  List pageList = [
    ObjetsPerdus(),
    AnnonceScreen(),
    HomePage(),
    InterclassePage(),
    ShopScreen()
  ];

  void _onSelected(newIndex) {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
    changerPage(context, pageList[newIndex]);
  }

  NavigationDestination _destination(
      String imagePath, String finalPath, String label, double width) {
    return NavigationDestination(
      icon: Image(
        image: ResizeImage(
          AssetImage(imagePath),
          width: 40,
          height: 40,
        ),
        width: width,
      ),
      selectedIcon: Image(
        image: ResizeImage(
          AssetImage(finalPath),
          width: 40,
          height: 40,
        ),
        width: width,
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        overlayColor: WidgetStatePropertyAll(Colors.white),
        backgroundColor: Colors.white,
        indicatorColor: Colors.white,
        indicatorShape: CircleBorder(),
        selectedIndex: widget.pageIndex,
        onDestinationSelected: _onSelected,
        height: 60,
        destinations: [
          _destination('assets/images/Navbar-Icons/loupe.png',
              'assets/images/Navbar-Icons/loupe-selected.png', '', 30),
          _destination("assets/images/Navbar-Icons/megaphone.png",
              "assets/images/Navbar-Icons/megaphone1.png", '', 30),
          _destination('assets/images/Navbar-Icons/home.png',
              'assets/images/Navbar-Icons/home1.png', '', 30),
          _destination('assets/images/Navbar-Icons/interclasse.png',
              'assets/images/Navbar-Icons/interclasse1.png', '', 30),
          _destination('assets/images/Navbar-Icons/shop.png',
              'assets/images/Navbar-Icons/shop1.png', '', 30),
        ],
      ),
    );
  }
}
