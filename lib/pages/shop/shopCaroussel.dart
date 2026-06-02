import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/pages/shop/shop_blouson.dart';
import 'package:new_app/widgets/app_loader.dart';

class ShopCarousel extends StatefulWidget {
  final List<String> imagePaths;
  Collection collection;

  ShopCarousel({super.key, required this.collection, required this.imagePaths});

  @override
  _ShopCarouselState createState() => _ShopCarouselState();
}

class _ShopCarouselState extends State<ShopCarousel> {
  int _currentPage = 0;
  late Timer _timer;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < widget.imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  Future<ImageProvider> _getCachedResizedImage(
      String imageUrl, int height) async {
    return ResizeImage(
      CachedNetworkImageProvider(imageUrl),
      height: height,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return FutureBuilder<ImageProvider>(
                future: _getCachedResizedImage(widget.imagePaths[index], 650),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: AppLoader());
                  } else if (snapshot.hasError) {
                    return Center(child: Icon(Icons.error));
                  } else {
                    return Image(
                      image: snapshot.data!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                    );
                  }
                },
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imagePaths.map((url) {
                int index = widget.imagePaths.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xffffdead).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nouvelle Collection',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        color: Colors.black,
                        fontFamily: 'LeagueGothicRegular-Regular',
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.account_tree,
                            color: Colors.black, size: 30.0),
                        Text('  ${widget.imagePaths.length} pieces'),
                      ],
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Redirection vers la page du produit
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  blousonPage(widget.collection)),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tout voir',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
