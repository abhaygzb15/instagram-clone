import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/utils/colors.dart';

// To run this use : flutter run -d chrome --web-renderer html

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: SvgPicture.asset(
            'assets/ic_instagram.svg',
            color: primaryColor,
            height: 32,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _page == 0 ? primaryColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(0),
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: _page == 1? primaryColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(1),
            ),
            IconButton(
              icon: Icon(
                Icons.add_a_photo,
                color: _page == 2? primaryColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(2),
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: _page == 3? primaryColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(3),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _page == 4 ? primaryColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(4),
            ),
          ],
        ),
        // body: Text('This is web')
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ) ,
      // )
    );
  }
}



