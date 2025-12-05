// import 'package:flutter/material.dart';
// import 'package:octagon/model/user_profile_response.dart';
// import 'package:octagon/screen/edit_profile/edit_profile.dart';
// import 'package:octagon/screen/login/login_screen.dart';
// import 'package:octagon/screen/login/reset_pasaword_screen.dart';
// import 'package:octagon/screen/setting/your_groups_screen.dart';
// import 'package:octagon/screen/sport%20/sport_selection_screen.dart';
// import 'package:octagon/screen/tabs_screen.dart';
// import 'package:octagon/widgets/webview_screen.dart';

// import 'package:share_plus/share_plus.dart';

// import '../main.dart';
// import '../networking/model/response_model/SportInfoModel.dart';
// import '../networking/model/user_response_model.dart';

// import '../utils/analiytics.dart';
// import '../utils/constants.dart';
// import '../utils/string.dart';
// import '../utils/theme/theme_constants.dart';
// import 'block_user_screen.dart';

// class SettingScreen extends StatefulWidget {
//   UserProfileResponseModel? profileData;

//   SettingScreen({Key? key, this.profileData}) : super(key: key);

//   @override
//   State<SettingScreen> createState() => _SettingScreenState();
// }

// class _SettingScreenState extends State<SettingScreen> {
//   /// dividers
//   final SizedBox _menuDividerNormal = const SizedBox(height: 15);
//   final SizedBox _menuSectionDividerSmall = const SizedBox(height: 10);
//   final SizedBox _menuSectionDivider = const SizedBox(height: 25);
//   final SizedBox _menuRowDivider = const SizedBox(width: 10);
//   late List<Widget> accountsMenuRows;
//   late List<Widget> contentAndDisplayRows;
//   late List<Widget> teams;
//   late List<Widget> cacheAndCellularRows;
//   late List<Widget> aboutMenuRows;
//   late List<Widget> groupsMenuRows;
//   List<Sports> sportDataList = [];

//   // late PostBloc postBloc;

//   @override
//   void initState() {
//     super.initState();

//     //postBloc = PostBloc();

//     sportDataList = [];

//     var data = storage.read(sportInfo);
//     if (data != null) {
//       (data as List).forEach((element) {
//         SportInfo value = SportInfo.fromJson(element);

//         sportDataList.add(Sports("${value.strSport}", value.id!.toInt(), value.idSport!.toInt(), value.strSportThumb.toString(), selected: true));
//       });

//       print(data);
//     }

//     // for (var element in event.data!.success!.sportInfo!) {
//     //   sportDataList.add(Sports(
//     //       "${element.strSport}",
//     //       element.id!.toInt(),
//     //       element.idSport!.toInt(),
//     //       element.strSportThumb.toString(),
//     //       selected: true));
//     // }

//     /// initialing menu list rows

//     accountsMenuRows = [
//       _menuRowWithFunction(Icons.person, "Edit Profile", () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => EditProfileScreen(
//                       profileData: widget.profileData?.success?.user,
//                       update: (UserModel data) {},
//                     )));
//       }),
//       _menuRowWithFunction(Icons.password_outlined, "Reset Password", () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassScreen()));
//       }),
//       _menuRowWithFunction(Icons.delete, "Delete account", () {
//         showDeleteDialog(() {
//           //postBloc.deleteUserAccount(userId: "${storage.read("current_uid")}");
//         });
//       })
//     ];
//     teams = [
//       _menuRowWithFunction(Icons.person, "Teams", () {
//         ///open sport selection form here as update.
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => SportSelection(
//                       sportDataList: sportDataList,
//                       isUpdate: true,
//                     )));
//       }),
//     ];
//     contentAndDisplayRows = [
//       _menuRowWithFunction(Icons.notifications, "Notification", () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => TabScreen(
//                       selectedPage: 2,
//                     )));
//       }),
//       _menuRowWithFunction(Icons.near_me_rounded, "Share", () {
//         Share.share('My Favourite app for sports https://octagonapp.com/app-download');

//         ///${Platform.isIOS ? "https://apps.apple.com/us/app/octagon-app/id1673110067":"https://play.google.com/store/apps/details?id=com.octagon.app"}
//       }),
//       _menuRowWithFunction(Icons.person_off, "Blocked Users", () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => BlockUserListScreen()));
//       }),
//     ];
//     cacheAndCellularRows = [
//       _menuRowWithFunction(Icons.delete_rounded, "Clear Cache", () {
//         _handleForgetMeClick.call(context, title: 'This will clear local cache memory!.', onYes: () {});
//       }),
//     ];
//     aboutMenuRows = [
//       _menuRowWithFunction(Icons.contact_support_rounded, "Contact Us", () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => WebViewScreen(
//                       screenName: "Contact Us",
//                       url: contactUsUrl,
//                     )));
//       }),
//       _menuRowWithFunction(Icons.lock, "Privacy Policy", () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => WebViewScreen(
//                       screenName: "Privacy Policy",
//                       url: privacyPolicyURL,
//                     )));
//       }),
//       // _menuRowWithRoute(
//       //     Icons.supervisor_account, "Octagon Lab", "/setting")
//     ];
//     groupsMenuRows = [
//       _menuRowWithFunction(Icons.groups, "Your Groups", () {
//         // Navigate to Your Groups screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => YourGroupsScreen(), // <- Replace with your actual groups screen
//           ),
//         );
//       }),
//     ];

//     /*postBloc.deleteUserAccountDataStream.listen((event) {
//       switch (event.status) {
//         case Status.LOADING:
//           break;
//         case Status.COMPLETED:

//           Get.snackbar(AppName, "Your account is delete now.");
//           _handleLogoutClick(context);
//           // setState(() {
//           //   isBlocked = !isBlocked;
//           // });
//           print(event.data);
//           break;
//         case Status.ERROR:
//           print(Status.ERROR);
//           break;
//         case null:
//           // TODO: Handle this case.
//       }
//     });*/

//     publishAmplitudeEvent(eventType: 'Setting $kScreenView');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: appBgColor,
//         body: SafeArea(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(children: [
//                 _buildHeader(),
//                 _menuSectionDividerSmall,
//                 _menuSection(menuList: _commonMenu(accountsMenuRows), titleString: "Account"),
//                 _menuSectionDivider,
//                 _menuSection(menuList: _commonMenu(groupsMenuRows), titleString: "Groups"),
//                 _menuSectionDivider,
//                 _menuSection(menuList: _commonMenu(teams), titleString: "Teams"),
//                 _menuSectionDivider,
//                 _menuSection(menuList: _commonMenu(contentAndDisplayRows), titleString: "Content"),
//                 _menuSectionDivider,
//                 _menuSection(menuList: _commonMenu(cacheAndCellularRows), titleString: "Cache"),
//                 _menuSectionDivider,
//                 _menuSection(menuList: _commonMenu(aboutMenuRows), titleString: "About"),
//                 _menuSectionDividerSmall,
//                 _commonButton("Logout", () => _handleLogoutClick(context)),
//                 _menuSectionDividerSmall,
//                 appData()
//               ]),
//             ),
//           ),
//         ));
//   }

//   Text appData() {
//     return const Text("Octagon 0.0.1/Build 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold));
//   }

//   Widget _commonButton(String btnTitle, Function() toExec, {Color btnColor = Colors.deepPurple}) {
//     return ElevatedButton(
//         style: ElevatedButton.styleFrom(
//             backgroundColor: btnColor,
//             // primary: btnColor,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
//         onPressed: () => toExec(),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
//           child: Text(btnTitle, style: TextStyle(color: Colors.white)),
//         ));
//   }

//   /// menu section container props
//   final BoxDecoration _menuContainerDecoration = BoxDecoration(
//     borderRadius: BorderRadius.circular(8),
//     // color: Color(0xff653FF61A),
//     color: purpleColor,
//   );

//   BoxConstraints _menuContainerConstraints(BuildContext ctxt) => BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.15);

//   /// menu list item navigation arrow
//   Widget navArrow(String routeName, {Function()? toCall}) {
//     return Ink(
//         child: InkWell(
//             onTap: () {
//               if (toCall != null) toCall.call();
//               Navigator.pushNamed(context, routeName);
//             },
//             child: const Icon(Icons.arrow_forward_ios_sharp, color: Colors.white)));
//   }

//   /// menu list row (routable) - icon, menu item title, screen route
//   Widget _menuRowWithRoute(IconData icon, String rowTitle, String routeName, {Function()? toCall}) {
//     const _style = TextStyle(color: Colors.white);
//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Stack(
//         children: [
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Row(
//               children: [
//                 Icon(icon, color: Colors.white),
//                 _menuRowDivider,
//                 Text(rowTitle, style: _style),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: navArrow(routeName, toCall: toCall),
//           )
//         ],
//       ),
//     );
//   }

//   /// menu list row (function call) - icon, menu item title, calls a function on button click
//   Widget _menuRowWithFunction(IconData icon, String rowTitle, Function() toCall) {
//     const _style = TextStyle(color: Colors.white);
//     return GestureDetector(
//       onTap: () {
//         toCall.call();
//       },
//       child: Container(
//         color: purpleColor,
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Row(
//                 children: [
//                   Icon(icon, color: Colors.white),
//                   _menuRowDivider,
//                   Text(rowTitle, style: _style),
//                 ],
//               ),
//             ),
//             Align(
//               alignment: Alignment.centerRight,
//               child: _callbackBtn(() {
//                 toCall.call();
//               }),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Ink _callbackBtn(Function() toCall) {
//     return Ink(
//         child: InkWell(
//             onTap: () {
//               toCall.call();
//             },
//             child: const Icon(Icons.arrow_forward_ios_sharp, color: Colors.grey)));
//   }

//   Widget _commonMenu(List<Widget> rows) {
//     return Container(
//       decoration: _menuContainerDecoration,
//       constraints: _menuContainerConstraints(context),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: rows,
//         ),
//       ),
//     );
//   }

//   /// menu section wrapper - title, spacing divider, menu list
//   Widget _menuSection({String titleString = "", required Widget menuList}) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [_menuSectionTitle(titleString), _menuDividerNormal, menuList],
//         ),
//       ],
//     );
//   }

//   /// menu title row wrapper
//   Widget _menuSectionTitle(String title) {
//     const _titleStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [Text(title, style: _titleStyle)],
//     );
//   }

//   void _handleForgetMeClick(BuildContext context, {String title = "", required Function onYes}) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Octagon'),
//           content: Text(title),
//           actions: <Widget>[
//             InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               // Closes the dialog
//               child: Container(
//                   padding: EdgeInsets.all(5),
//                   child: const Text(
//                     'No',
//                     style: TextStyle(fontSize: 16),
//                   )),
//             ),
//             InkWell(
//               onTap: () {
//                 onYes.call();
//                 Navigator.pop(context); // Closes the dialog
//               },
//               child: Container(padding: EdgeInsets.all(5), child: const Text('Yes', style: TextStyle(fontSize: 16))),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _handleLogoutClick(BuildContext context) {
//     _handleForgetMeClick.call(context, title: 'Are you sure want to logout!.', onYes: () {
//       storage.erase().then((value) {
//         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (Route route) => false);
//       });
//     });
//   }

//   _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Icon(Icons.close, size: 36, color: Colors.transparent),
//         Container(
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(10),
//           child: const Text(
//             "Setting",
//             style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
//           ),
//         ),
//         GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: const Icon(Icons.close, size: 36, color: Colors.white))
//       ],
//     );
//   }

//   showDeleteDialog(Function onDeletePostPress) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Are you sure?'),
//           content: const Text('This will delete this account permanently.'),
//           actions: <Widget>[
//             InkWell(
//               onTap: () => Navigator.pop(context),
//               // Closes the dialog
//               child: Container(padding: EdgeInsets.all(5), child: const Text('No', style: TextStyle(fontSize: 16))),
//             ),
//             InkWell(
//               onTap: () {
//                 onDeletePostPress.call();
//                 Navigator.pop(context); // Closes the dialog
//               },
//               child: Container(padding: EdgeInsets.all(5), child: const Text('Yes', style: TextStyle(fontSize: 16))),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
