import 'package:flutter/material.dart';
import 'package:new_app/widgets/reusable_widgets.dart';

class VolleyballPage extends StatefulWidget {
  const VolleyballPage({super.key});

  @override
  _VolleyballPageState createState() => _VolleyballPageState();
}

class _VolleyballPageState extends State<VolleyballPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.orange.withValues(alpha: 0.5),
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/images/volleyball/volley_top_bg.jpg',
                    height: 200,
                    fit: BoxFit.cover,
                    opacity: AlwaysStoppedAnimation(0.3),
                  ),
                  Positioned(
                    left: 10,
                    top: 50,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 160,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        "assets/images/Competition/logo_volley.png",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Text(
              'Volleyball',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MemberCard(title: 'Président'),
                      SizedBox(
                        width: 10,
                      ),
                      MemberCard(title: 'Vice-Président'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Prochain-évènement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.play_arrow, size: 50),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Lorem ipsum dolor sit amet consectetur. Quis faucibus lacus integer nisi. Aenean amet amet libero duis sollicitudin blandit sed...',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Matchs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final String title;
  const MemberCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
        ),
        SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}
