import 'dart:async';
// import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get/get.dart';

import 'package:octagon/screen/mainFeed/home/home_controller.dart';
import 'package:octagon/screen/mainFeed/home/new_homecontroller.dart';
import 'package:octagon/screen/notification/notification_screen.dart';
import 'package:octagon/screen/profile/profile_screen.dart';

import 'package:octagon/screen/tranding/tranding_screen.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/tab_bar_widget.dart';

import '../utils/analiytics.dart';

import '../utils/string.dart';
import 'common/full_screen_post.dart';
import 'mainFeed/main_feed_screen.dart';

var currentPage = StreamController<int>.broadcast();

bool isMute = false;

class TabScreen extends StatefulWidget {
  int selectedPage = 0;

  TabScreen({this.selectedPage = 0, Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  final _inactiveColor = Colors.grey;
  List<Widget> pages = [];
  final HomeController controller = Get.find<HomeController>();
  final NewHomecontroller newHomeController = Get.find<NewHomecontroller>();

  // AppLinks _appLinks = AppLinks(); // AppLinks is singleton
  StreamSubscription<Uri>? _linkSubscription;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    currentPage.add(widget.selectedPage);

    pages = [HomeScreen(), TrendingScreen(), NotificationScreen(), ProfileScreen()];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentPage.add(0);
    });

    // initFirebaseNotifications();

    publishAmplitudeEvent(eventType: 'Tab Screen $kScreenView');

    // versionCheck(context);

    // initDeepLinks();
  }

  // Future<void> initDeepLinks() async {
  //   _appLinks = AppLinks();

  //   // Handle links
  //   _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
  //     debugPrint('onAppLink: $uri');
  //     openAppLink(uri);
  //   });
  // }

  void openAppLink(Uri uri) {
    if (uri.pathSegments.length > 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullScreenPost(
                    postId: uri.pathSegments[1],
                    updateData: () {},
                  )));
    }
    // _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: currentPage.stream,
        builder: (context, AsyncSnapshot<int> value) {
          int data = value.hasData ? value.data ?? 0 : widget.selectedPage;

          return WillPopScope(
            onWillPop: () {
              if (widget.selectedPage != 0) {
                setState(() {
                  widget.selectedPage = 0;
                });
              }
              return Future.value(data == 0);
            },
            child: Scaffold(
              body: pages.elementAt(data),
              /*PageTransitionSwitcher(
              transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  ) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: pages[_page]['page'],
            ),*/
              // floatingActionButton: FloatingActionButton(
              //   onPressed: (){
              //     Navigator.push(context, MaterialPageRoute(
              //         builder: (context) => const ScoreScreen()));
              //   },
              // ),
              bottomNavigationBar: _buildBottomBar(
                  data), /*BottomAppBar(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 5),
                  for (Map item in pages)
                     Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: IconButton(
                        icon: Icon(
                          item['icon'],
                          color: item['index'] != _page
                              ? Colors.grey
                              : Theme.of(context).accentColor,
                          size: 20.0,
                        ),
                        onPressed: () => navigationTapped(item['index']),
                      ),
                    ),
                  SizedBox(width: 5),
                ],
              ),
            ),*/
            ),
          );
        });
  }

  // void navigationTapped(int page) {
  //   setState(() {
  //     widget.selectedPage = page;
  //   });
  //   currentPage.add(widget.selectedPage);
  // }
  Widget _buildBottomBar(int data) {
    return CustomAnimatedBottomBar(
      containerHeight: 60,
      backgroundColor: Colors.black,
      selectedIndex: data,
      showElevation: true,
      itemCornerRadius: 12,
      curve: Curves.easeIn,
      onItemSelected: (index) {
        if (widget.selectedPage == 0) {
          // controller.refreshPage();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.scrollController.hasClients) {
              controller.scrollController.jumpTo(0); // or any offset
            }
          });
          // Future.delayed(Duration(milliseconds: 1000));
          // controller.scrollController.jumpTo(0);

          newHomeController.pagingController?.refresh();
        } else {
          // controller.scrollController.dispose();
          widget.selectedPage = index;
          currentPage.add(widget.selectedPage);
        }
        widget.selectedPage = index;
        currentPage.add(widget.selectedPage);
      },
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: const Icon(Icons.home),
          title: const Text('Home'),
          activeColor: purpleColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        // BottomNavyBarItem(
        //   icon: const Icon(Feather.search),
        //   title: const Text('Users'),
        //   activeColor: purpleColor,
        //   inactiveColor: _inactiveColor,
        //   textAlign: TextAlign.center,
        // ),
        BottomNavyBarItem(
          icon: const Icon(Feather.trending_up),
          title: Text('Users'),
          activeColor: purpleColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Feather.bell),
          title: const Text(
            'Notification',
          ),
          activeColor: purpleColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: const Icon(Icons.person),
          title: const Text('Settings'),
          activeColor: purpleColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget getBody() {
  //   return IndexedStack(
  //     index: widget.selectedPage,
  //     children: pages,
  //   );
  // }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }
}
