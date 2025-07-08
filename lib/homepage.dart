import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplore_app/Homepage/screen1.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentindex = 0;
  final List<Widget> screen = [HomeScreen1(),Scaffold(body: Center(child: Text("coming1"))),Scaffold(body: Center(child: Text("coming2"))),Scaffold(body: Center(child: Text("coming3")))];
  @override
  void initState() {
    super.initState();
    currentindex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
        const Color.fromRGBO(245, 245, 245, 1), // Optional for contrast
      body: Stack(
        children: [
          screen[currentindex],
          CustomBottomNavBar(
            currentindex: currentindex,
            onTap: (int index) {
              setState(() {
                currentindex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

//bottomnavigationbar
class CustomBottomNavBar extends StatelessWidget {
  final int currentindex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentindex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.69),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => onTap(0),
              icon: const Icon(Icons.home),
              iconSize: 30,
              color: (currentindex == 0) ? Colors.black : Colors.grey,
            ),
            IconButton(
              onPressed: () => onTap(1),
              icon: SvgPicture.asset(
                'assets/icons/homenav.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  (currentindex == 1) ? Colors.black : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            IconButton(
              onPressed: () => onTap(2),
              icon: const Icon(Icons.group),
              iconSize: 30,
              color: (currentindex == 2) ? Colors.black : Colors.grey,
            ),
            IconButton(
              onPressed: () => onTap(3),
              icon: const Icon(Icons.person),
              iconSize: 30,
              color: (currentindex == 3) ? Colors.black : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}


