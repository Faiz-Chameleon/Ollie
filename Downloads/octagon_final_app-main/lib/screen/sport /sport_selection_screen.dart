// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get.dart';
// import 'package:octagon/main.dart';

// import 'package:octagon/networking/model/response_model/sport_list_response_model.dart';
// import 'package:octagon/networking/model/save_sports_request_model.dart';
// import 'package:octagon/networking/response.dart';
// import 'package:octagon/screen/chat/new_groupchat_screen.dart';
// import 'package:octagon/screen/login/login_controller.dart';

// import 'package:octagon/screen/login/login_screen.dart';
// import 'package:octagon/screen/sport%20/bloc/sport_bloc.dart';
// import 'package:octagon/screen/sport%20/bloc/sport_event.dart';
// import 'package:octagon/screen/sport%20/bloc/sport_state.dart';
// import 'package:octagon/screen/tabs_screen.dart';
// import 'package:octagon/screen/term_selection/team_selection.dart';
// import 'package:octagon/utils/analiytics.dart';
// import 'package:octagon/utils/constants.dart';
// import 'package:octagon/utils/octagon_common.dart';
// import 'package:octagon/utils/string.dart';
// import 'package:octagon/utils/theme/theme_constants.dart';
// import 'package:octagon/widgets/filled_button_widget.dart';
// import 'package:resize/resize.dart';
// import 'package:shape_maker/shape_maker.dart';

// import '../../utils/common_image_view.dart';
// import '../../utils/svg_to_png.dart';
// import 'group_controller.dart';

// class SportSelection extends StatefulWidget {
//   List<Sports>? sportDataList;
//   bool isUpdate = false;

//   SportSelection({Key? key, this.sportDataList, this.isUpdate = false}) : super(key: key);

//   @override
//   State<SportSelection> createState() => _SportSelectionState();
// }

// class _SportSelectionState extends State<SportSelection> {
//   List<SaveSport> selectedSportsList = [];
//   List<Sports> sportDataList = [];
//   SportBloc sportBloc = SportBloc();
//   List<SportListResponseModelData> sportListResponseModel = [];

//   bool isLoading = false;
//   final NewGroupController groupController = Get.put(NewGroupController());

//   // List<SaveSportListResponseModelData> saveSportListResponseModelData = [];

//   @override
//   void initState() {
//     super.initState();
//     groupController.fetchGroupData();
//   }
//   // @override
//   // void initState() {
//   //   sportBloc = SportBloc();

//   //   sportBloc.add(GetSportListEvent());

//   //   publishAmplitudeEvent(eventType: 'Sports Selection $kScreenView');
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: SafeArea(
//         child: Scaffold(
//           bottomNavigationBar: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: GestureDetector(
//               onTap: () async {
//                 if (groupController.selectedGroupId.value != 0) {
//                   await groupController.joinGroup();
//                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabScreen()));
//                 } else {
//                   Get.snackbar("Groups", "Please select a group", backgroundColor: Colors.white, colorText: Colors.black);
//                 }
//               },
//               child: Container(
//                 width: 327,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: purpleColor,
//                 ),
//                 child: Obx(() {
//                   return !groupController.isLoadingOnJoin.value
//                       ? Center(
//                           child: Text(
//                             "Next",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: whiteColor,
//                             ),
//                           ),
//                         )
//                       : Center(
//                           child: CircularProgressIndicator(
//                             backgroundColor: Colors.white,
//                           ),
//                         );
//                 }),
//               ),
//             ),
//           ),
//           backgroundColor: appBgColor,
//           appBar: AppBar(
//             leading: InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: const Icon(
//                 Icons.arrow_back_ios,
//                 color: Colors.white,
//               ),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//             title: Text(
//               "Select your favorite group",
//               style: whiteColor20BoldTextStyle,
//             ),
//             actions: [
//               if (!widget.isUpdate)
//                 InkWell(
//                   onTap: () {
//                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabScreen()));
//                   },
//                   child: Center(
//                     child: Text(
//                       "Skip  ",
//                       style: whiteColor20BoldTextStyle,
//                     ),
//                   ),
//                 )
//             ],
//           ),
//           body: ListView(
//             children: [
//               Obx(() {
//                 return groupController.isLoading.value
//                     ? const Center(child: CircularProgressIndicator())
//                     : groupController.groupData.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.group_off, size: 48, color: Colors.grey),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   "No groups available",
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : GridView.builder(
//                             physics: NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                             ),
//                             itemCount: groupController.groupData.length,
//                             itemBuilder: (context, index) {
//                               final group = groupController.groupData[index];

//                               return Obx(() {
//                                 final isSelected = groupController.selectedGroupId.value == group['id'];
//                                 print("Is Selected: $isSelected");

//                                 return InkWell(
//                                   onTap: () {
//                                     groupController.updateSelectedGroupId(group['id']);

//                                     // Save to storage
//                                     storage.write('userDefaultGroup', group['logo']);
//                                     storage.write('userDefaultGroupName', group['title']);
//                                   },
//                                   child: ClipPath(
//                                     clipper: OctagonClipper(),
//                                     child: CustomPaint(
//                                       painter: OctagonBorderPainter(
//                                         borderColor: isSelected ? purpleColor : greyColor, // Change border color
//                                       ),
//                                       child: Padding(
//                                         padding: EdgeInsets.all(5),
//                                         child: ClipPath(
//                                           clipper: OctagonClipper(),
//                                           child: Image.network(
//                                             "http://3.134.119.154/${group['photo']}",
//                                             width: 50,
//                                             height: 50,
//                                             fit: BoxFit.fill,
//                                             errorBuilder: (context, error, stackTrace) {
//                                               // Fallback image if network image fails to load
//                                               return Padding(
//                                                 padding: EdgeInsets.all(5),
//                                                 child: ClipPath(
//                                                   clipper: OctagonClipper(),
//                                                   child: Image.network(
//                                                     'https://www.shutterstock.com/shutterstock/photos/1737334631/display_1500/stock-vector-image-not-found-grayscale-image-photo-1737334631.jpg', // Dummy image
//                                                     width: 50,
//                                                     height: 50,
//                                                     fit: BoxFit.fill,
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               });
//                             },
//                           );
//               }),
//               Spacer(),
//               // Padding(
//               //     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//               //     child: FilledButtonWidget(isLoading: groupController.isLoadingOnJoin.value, "Next", () async {
//               //       if (groupController.selectedGroupId.value != 0) {
//               //         await groupController.joinGroup();
//               //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabScreen()));
//               //       } else {
//               //         Get.snackbar("Groups", "Please select a group");
//               //       }
//               //     }, 1)),
//             ],
//           ),
//           // body: BlocConsumer(
//           //     bloc: sportBloc,
//           //     listener: (context, state) {
//           //       if (state is SportLoadingBeginState) {
//           //         // onLoading(context);
//           //         isLoading = true;
//           //         setState(() {});
//           //       }
//           //       if (state is GetSportListSate) {
//           //         // stopLoader(context);
//           //         isLoading = false;

//           //         setState(() {
//           //           sportListResponseModel =
//           //               state.sportListResponseModel.data ?? [];
//           //           for (var element in state.sportListResponseModel.data!) {
//           //             sportDataList.add(Sports(
//           //                 "${element.strSport}",
//           //                 element.id!.toInt(),
//           //                 element.idSport!.toInt(),
//           //                 element.strSportThumb.toString()));
//           //           }
//           //         });

//           //         if (widget.sportDataList != null &&
//           //             widget.sportDataList!.isNotEmpty) {
//           //           for (var data in widget.sportDataList!) {
//           //             int index = sportDataList.indexWhere(
//           //                 (element) => element.sportsId == data.sportsId);
//           //             widget.sportDataList![index] = data;
//           //           }
//           //         }
//           //       }
//           //       if (state is SaveSportState) {
//           //         // stopLoader(context);
//           //         isLoading = false;
//           //         setState(() {});
//           //         Navigator.push(
//           //             context,
//           //             MaterialPageRoute(
//           //                 builder: (context) => TeamSelectionScreen(
//           //                     sportDataList,
//           //                     isUpdate: widget.isUpdate)));
//           //       }
//           //     },
//           //     builder: (context, _) {
//           //       return Column(
//           //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //         children: [
//           //           Expanded(
//           //             child: SingleChildScrollView(
//           //               physics: const BouncingScrollPhysics(
//           //                   parent: AlwaysScrollableScrollPhysics()),
//           //               child: Wrap(
//           //                 spacing: 15,
//           //                 children: getSportsSelection(),
//           //               ),
//           //             ),
//           //           ),
//           //           Padding(
//           //               padding: const EdgeInsets.symmetric(
//           //                   vertical: 20, horizontal: 10),
//           //               child: FilledButtonWidget(
//           //                   isLoading: isLoading, /*widget.model,*/ "Next", () {
//           //                 if (selectedSportsList.isNotEmpty) {
//           //                   sportBloc.add(
//           //                       SaveSportListEvent(sports: selectedSportsList));
//           //                 } else {
//           //                   Get.snackbar("Groups", "please select any one");
//           //                 }
//           //               }, 1)),
//           //         ],
//           //       );
//           //     }),
//         ),
//       ),
//     );
//   }

//   getSportsSelection() {
//     List<Widget> list = [];
//     for (int i = 0; i < sportDataList.length; i++) {
//       list.add(getSports(i));
//     }
//     return list;
//   }

//   getSports(int index) {
//     /*  for (var element in selectedLanguages) {
//       if(element == language[index].language){
//         language[index].isSelected = true;
//       }
//     }*/
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           sportDataList.forEach((element) {
//             element.selected = false;
//           });
//           sportDataList[index].selected = !sportDataList[index].selected;

//           selectedSportsList = [];
//           selectedSportsList.add(SaveSport(sportId: sportDataList[index].sportsId, sportApiId: sportDataList[index].sportApiId));

//           // sportDataList[index].selected
//           //     ? selectedSportsList.add(SaveSport(
//           //     sportId: sportDataList[index].sportsId,
//           //     sportApiId: sportDataList[index].sportApiId))
//           //     : selectedSportsList.remove(SaveSport(
//           //     sportId: sportDataList[index].sportsId,
//           //     sportApiId: sportDataList[index].sportApiId));
//         });
//       },
//       child: Container(
//         height: 130,
//         width: 100,
//         margin: EdgeInsets.symmetric(vertical: 4.h),
//         child: Column(
//           children: <Widget>[
//             buildSportSelectionWidget(isSelected: sportDataList[index].selected, image: sportDataList[index].sportsImage),
//             SizedBox(
//               height: 2.h,
//             ),
//             Expanded(
//               child: Text(
//                 sportDataList[index].sportsName,
//                 textAlign: TextAlign.center,
//                 style: whiteColor14BoldTextStyle,
//                 maxLines: 1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> _onWillPop() async {
//     if (widget.isUpdate) {
//       return Future(() => true);
//     }
//     return (await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text("Octagon"),
//             content: const Text("Are you sure you want to exit the app!"),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text("No"),
//               ),
//               TextButton(
//                 onPressed: () => exit(0),
//                 child: const Text("Yes"),
//               ),
//             ],
//           ),
//         )) ??
//         false;
//   }
// }
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/main.dart';
import 'package:http/http.dart' as http;

import 'package:octagon/networking/model/response_model/sport_list_response_model.dart';
import 'package:octagon/networking/model/save_sports_request_model.dart';
import 'package:octagon/networking/response.dart';
import 'package:octagon/screen/login/login_controller.dart';
import 'package:octagon/screen/login/login_screen.dart';
import 'package:octagon/screen/sport%20/bloc/sport_bloc.dart';
import 'package:octagon/screen/sport%20/bloc/sport_event.dart';
import 'package:octagon/screen/sport%20/bloc/sport_state.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/screen/term_selection/team_selection.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';

import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:resize/resize.dart';

import '../../utils/common_image_view.dart';
import '../../utils/svg_to_png.dart';
import 'group_controller.dart';
import 'octagon_shapes.dart';

class SportSelection extends StatefulWidget {
  List<Sports>? sportDataList;
  bool isUpdate = false;

  SportSelection({Key? key, this.sportDataList, this.isUpdate = false}) : super(key: key);

  @override
  State<SportSelection> createState() => _SportSelectionState();
}

class _SportSelectionState extends State<SportSelection> {
  List<SaveSport> selectedSportsList = [];
  List<Sports> sportDataList = [];
  SportBloc sportBloc = SportBloc();
  List<SportListResponseModelData> sportListResponseModel = [];

  bool isLoading = false;
  final NewGroupController groupController = Get.put(NewGroupController());

  @override
  void initState() {
    super.initState();
    groupController.fetchGroupData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                if (groupController.selectedGroupId.value != 0) {
                  await groupController.joinGroup();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabScreen()));
                } else {
                  Get.snackbar("Groups", "Please select a group", backgroundColor: Colors.white, colorText: Colors.black);
                }
              },
              child: Container(
                width: 327,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: purpleColor,
                ),
                child: Obx(() {
                  return !groupController.isLoadingOnJoin.value
                      ? Center(
                          child: Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: whiteColor,
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        );
                }),
              ),
            ),
          ),
          backgroundColor: appBgColor,
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Select your favorite group",
              style: whiteColor20BoldTextStyle,
            ),
            actions: [
              if (!widget.isUpdate)
                InkWell(
                  onTap: () async {
                    try {
                      // Show a loading indicator while the API call is in progress
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(child: CircularProgressIndicator()),
                      );

                      // Make the API call
                      final request = await http.MultipartRequest(
                        'POST',
                        Uri.parse('http://3.134.119.154/api/join-default-group'),
                      );
                      request.headers['Authorization'] = 'Bearer ${getUserToken()}';
                      request.fields['email'] = 'admin@octagon.com';
                      request.fields['password'] = '12345678';

                      final streamedResponse = await request.send();
                      final response = await http.Response.fromStream(streamedResponse);
                      ;

                      Navigator.pop(context); // Close the loading indicator

                      if (response.statusCode == 200) {
                        // Navigate to the TabScreen on success
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TabScreen()),
                        );
                      } else {
                        // Show an error message if the API call fails
                        Get.snackbar(
                          'Error',
                          'Failed to join the default group. Please try again.',
                          backgroundColor: Colors.white,
                          colorText: Colors.black,
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context); // Close the loading indicator

                      // Show an error message if an exception occurs
                      Get.snackbar(
                        'Error',
                        'An error occurred: $e',
                        backgroundColor: Colors.white,
                        colorText: Colors.black,
                      );
                    }
                  },
                  child: Center(
                    child: Text(
                      "Skip  ",
                      style: whiteColor20BoldTextStyle,
                    ),
                  ),
                )
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) => groupController.filterUsers(value),
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by Group name',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF232042),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Obx(() {
                return groupController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : groupController.groupData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group_off, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "No groups available",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: GridView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                // mainAxisExtent: 120,
                                // childAspectRatio: 0.5,
                              ),
                              itemCount:
                                  groupController.filteredgroups.isEmpty ? groupController.groupData.length : groupController.filteredgroups.length,
                              // itemCount: groupController.groupData.length,
                              itemBuilder: (context, index) {
                                final group =
                                    groupController.filteredgroups.isEmpty ? groupController.groupData[index] : groupController.filteredgroups[index];

                                return Obx(() {
                                  final isSelected = groupController.selectedGroupId.value == group['id'];
                                  print("Is Selected: $isSelected");

                                  return InkWell(
                                    onTap: () {
                                      groupController.updateSelectedGroupId(group['id']);

                                      // Save to storage
                                      storage.write('userDefaultGroup', group['logo']);
                                      storage.write('userDefaultGroupName', group['title']);
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ClipPath(
                                            clipper: OctagonClipper(),
                                            child: CustomPaint(
                                              painter: OctagonBorderPainter(
                                                borderColor: isSelected ? purpleColor : greyColor, // Change border color
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(5),
                                                child: ClipPath(
                                                  clipper: OctagonClipper(),
                                                  child: group['title'] == "Octagon"
                                                      ? Image.asset(
                                                          "assets/ic/Group 4.png",
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.network(
                                                          "http://3.134.119.154/${group['photo']}",
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            // Fallback image if network image fails to load
                                                            return Padding(
                                                              padding: EdgeInsets.all(5),
                                                              child: ClipPath(
                                                                clipper: OctagonClipper(),
                                                                child: Image.network(
                                                                  'https://www.shutterstock.com/shutterstock/photos/1737334631/display_1500/stock-vector-image-not-found-grayscale-image-photo-1737334631.jpg', // Dummy image
                                                                  // width: 50,
                                                                  // height: 50,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                            group['title'],
                                            style: TextStyle(
                                              color: whiteColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              },
                            ),
                          );
              }),
            ],
          ),
        ),
      ),
    );
  }

  getSportsSelection() {
    List<Widget> list = [];
    for (int i = 0; i < sportDataList.length; i++) {
      list.add(getSports(i));
    }
    return list;
  }

  getSports(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          sportDataList.forEach((element) {
            element.selected = false;
          });
          sportDataList[index].selected = !sportDataList[index].selected;

          selectedSportsList = [];
          selectedSportsList.add(SaveSport(sportId: sportDataList[index].sportsId, sportApiId: sportDataList[index].sportApiId));
        });
      },
      child: Container(
        height: 130,
        width: 100,
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          children: <Widget>[
            buildSportSelectionWidget(isSelected: sportDataList[index].selected, image: sportDataList[index].sportsImage),
            SizedBox(
              height: 2.h,
            ),
            Expanded(
              child: Text(
                sportDataList[index].sportsName,
                textAlign: TextAlign.center,
                style: whiteColor14BoldTextStyle,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (widget.isUpdate) {
      return Future(() => true);
    }
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Octagon"),
            content: const Text("Are you sure you want to exit the app!"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: const Text("Yes"),
              ),
            ],
          ),
        )) ??
        false;
  }
}
