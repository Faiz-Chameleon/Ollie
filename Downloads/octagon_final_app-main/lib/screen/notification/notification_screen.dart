import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/model/notification_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:octagon/screen/profile/other_user_profile.dart';
import 'package:octagon/screen/tranding/bloc/tranding_bloc.dart';
import 'package:octagon/screen/tranding/bloc/tranding_event.dart';
import 'package:octagon/screen/tranding/bloc/tranding_state.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/time_extenstionn.dart';
import 'package:octagon/widgets/follow_button_widget.dart';
import 'package:resize/resize.dart';
import 'package:shape_maker/shape_maker.dart';
import '../../networking/model/notification_response.dart';
import '../../networking/response.dart';
import '../../widgets/loader_lottie.dart';
import '../tabs_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationData> notifications = [];

  bool isRefreshHome = false;

  TrendingBloc trendingBloc = TrendingBloc();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    trendingBloc = TrendingBloc();
    // notificationBloc.dataStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       setState(() {
    //         notifications = event.data!.success?.notification ?? [];
    //       });
    //       // print(event.data);
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       break;
    //     case null:
    //       // TODO: Handle this case.
    //   }
    // });

    getNotification();

    currentPage.stream.listen((event) {
      if (event == 2) {
        getNotification();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text("Notification", style: whiteColor20BoldTextStyle),
          centerTitle: true,
          leading: const SizedBox(),
        ),
        body: BlocConsumer(
            bloc: trendingBloc,
            listener: (context, state) {
              if (state is TrendingLoadingBeginState) {
                isLoading = true;
                // onLoading(context);
              }
              if (state is GetNotificationState) {
                // stopLoader(context);
                isLoading = false;
                notifications = state.notificationResponse.success?.notification ?? [];
              }
            },
            builder: (context, _) {
              return RefreshIndicator(
                child: Visibility(
                  visible: notifications.isNotEmpty,
                  replacement: isLoading
                      ? GestureDetector(
                          onTap: () {
                            getNotification();
                          },
                          child: SizedBox(
                            height: 68.vh,
                            width: 100.vw,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                loaderLottie()
                                // Text("Fetching data for you!!",
                                //     style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ))
                      : const Center(
                          child: Text(
                            "No Data Found",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return notificationItem(notifications[index]);
                        // return Slidable(
                        //   startActionPane: ActionPane(
                        //     motion: const DrawerMotion(),
                        //     extentRatio: 0.25,
                        //     children: [
                        //       SlidableAction(
                        //         label: 'info',
                        //         backgroundColor: greyColor,
                        //         icon: Icons.info_outlined,
                        //         onPressed: (context) {},
                        //       ),
                        //     ],
                        //   ),
                        //   endActionPane: ActionPane(
                        //     motion: const DrawerMotion(),
                        //     extentRatio: 0.25,
                        //     children: [
                        //       SlidableAction(
                        //         label: 'Delete',
                        //         backgroundColor: Colors.red,
                        //         icon: Icons.delete,
                        //         onPressed: (context) {},
                        //       ),
                        //     ],
                        //   ),
                        //   child: notificationItem(notifications[index]),
                        // );
                      }),
                ),
                onRefresh: () => _onRefreshHandler(context),
              );
            }));
  }

  notificationItem(NotificationData notification) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                /*  notification.hasStory ?
                Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.yellow, Colors.orangeAccent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomLeft
                      ),
                      // border: Border.all(color: Colors.red),
                      shape: BoxShape.circle
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: greyColor, width: 3)
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(notification.profilePic)
                    ),
                  ),
                ) :*/
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OtherUserProfileScreen(userId: notification.user!.first.id!)));
                  },
                  child: ShapeMaker(
                    height: 50,
                    width: 50,
                    bgColor: Colors.yellow,
                    widget: Container(
                      margin: const EdgeInsets.all(6),
                      child: ShapeMaker(
                        bgColor: Colors.black,
                        widget: Container(
                          margin: const EdgeInsets.all(8),
                          child: ShapeMaker(
                            bgColor: !isTrue(notification.user) ? Colors.white : appBgColor,
                            widget: !isTrue(notification.user)
                                ? null
                                : CachedNetworkImage(
                                    imageUrl: notification.user?.first.photo ?? "",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const SizedBox(height: 10),
                                    errorWidget: (context, url, error) => const Icon(Icons.error, size: 20),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: RichText(
                      text: TextSpan(children: [
                    // TextSpan(text: notification.name, style: whiteColor14BoldTextStyle),
                    TextSpan(text: "${notification.notification} ".capitalize!, style: whiteColor14TextStyle),
                    TextSpan(text: (notification.createdAt ?? DateTime.now()).timeAgo(numericDates: false), style: greyColor14TextStyle)
                  ])),
                )
              ],
            ),
          ),

          // notification.postImage != '' ?
          // Container(
          //   width: 50,
          //   height: 50,
          //   child: ClipRRect(
          //       child: Image.network(notification.postImage)
          //   ),
          // )
          //     : FollowButton(backgroundColor: purpleColor,text: "Follow",textStyle: whiteColor14BoldTextStyle,),
        ],
      ),
    );
  }

  Future<void> _onRefreshHandler(BuildContext context) async {
    isRefreshHome = true;
    getNotification();
  }

  void getNotification() {
    trendingBloc.add(GetNotificationEvent());
  }

  isTrue(List<User>? user) {
    if (user != null) {
      if (user.isNotEmpty) {
        if (user.firstOrNull?.photo != null) {
          return true;
        }
        return false;
      }
      return false;
    }
    return false;
  }
}
