import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/tranding/bloc/tranding_bloc.dart';
import 'package:octagon/screen/tranding/bloc/tranding_event.dart';
import 'package:octagon/screen/tranding/bloc/tranding_state.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:resize/resize.dart';
import '../../model/post_response_model.dart';
import '../../networking/response.dart';
import '../../utils/image_picker_inapp.dart';
import '../../utils/octagon_common.dart';
import '../../widgets/loader_lottie.dart';
import '../common/full_screen_post.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  List<PostResponseModelData> trendingDataList = [];
  List<PostResponseModelData> searchList = [];

  TrendingBloc trendingDataBloc = TrendingBloc();
  //PostBloc postBloc = PostBloc();
  var scrollController = ScrollController();
  String error = "Loading..";
  int currentPageNo = 1;
  bool visible = false;
  bool isRefresh = false;
  bool isLoading = false;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(pagination);

    trendingDataBloc = TrendingBloc();
    // postBloc = PostBloc();

    // trendingDataBloc.dataStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       setState(() {
    //         if (isRefresh) {
    //           trendingDataList.clear();
    //         }
    //
    //         searchList.clear();
    //         if(event.data!=null && event.data!.success!=null){
    //           for (var element in event.data!.success!) {
    //             // if(element.type == "1"){
    //             trendingDataList.add(element);
    //             searchList.add(element);
    //             // }else if(element.type == "2"){
    //             //   storiesDataList.add(element);
    //             // }
    //           }
    //         }
    //       });
    //       // print(event.data);
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       setState(() {
    //         error = event.message ?? "";
    //       });
    //       break;
    //     case null:
    //       // TODO: Handle this case.
    //   }
    // });
    //
    // postBloc.likePostDataStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       setState(() {
    //         event.data!.success.favorite;
    //       });
    //       // print(event.data);
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       setState(() {
    //         error = event.message ?? "";
    //       });
    //       break;
    //     case null:
    //       // TODO: Handle this case.
    //   }
    // });
    //
    // postBloc.savePostDataStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       setState(() {
    //         event.data!.success.favorite;
    //       });
    //       // print(event.data);
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       setState(() {
    //         error = event.message ?? "";
    //       });
    //       break;
    //     case null:
    //       // TODO: Handle this case.
    //   }
    // });
    //
    // postBloc.followUserDataStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       setState(() {
    //         event.data!.success;
    //       });
    //       // print(event.data);
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       setState(() {
    //         error = event.message ?? "";
    //       });
    //       break;
    //     case null:
    //       // TODO: Handle this case.
    //   }
    // });

    trendingDataBloc.add(GetTrendingEvent(type: "1"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBgColor,
        appBar: AppBar(
          leading: const SizedBox(),
          // leading: IconButton(
          //   icon: const Icon(Icons.camera_alt),
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen()));
          //   },
          // ),
          backgroundColor: appBgColor,
          elevation: 0.0,
          title: Text(
            "Octagon",
            style: whiteColor20BoldTextStyle,
          ),
          centerTitle: true,
          // actions: <Widget>[
          //   FocusedMenuHolder(
          //     menuWidth: MediaQuery.of(context).size.width * 0.50,
          //     blurSize: 5.0,
          //     menuItemExtent: 45,
          //     menuBoxDecoration: const BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(15.0))),
          //     duration: const Duration(milliseconds: 100),
          //     animateMenuItems: true,
          //     blurBackgroundColor: Colors.black54,
          //     openWithTap: true,
          //     // Open Focused-Menu on Tap rather than Long Press
          //     menuOffset: 10.0,
          //     // Offset value to show menuItem from the selected item
          //     bottomOffsetHeight: 80.0,
          //     // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
          //     menuItems: <FocusedMenuItem>[
          //       // Add Each FocusedMenuItem  for Menu Options
          //       FocusedMenuItem(
          //           title: const Text("Open"),
          //           trailingIcon: Icon(Icons.open_in_new),
          //           onPressed: () {
          //             // Navigator.push(context, MaterialPageRoute(builder: (context)=>ScreenTwo()));
          //           }),
          //       FocusedMenuItem(title: const Text("Share"), trailingIcon: Icon(Icons.share), onPressed: () {}),
          //       FocusedMenuItem(title: const Text("Favorite"), trailingIcon: Icon(Icons.favorite_border), onPressed: () {}),
          //       FocusedMenuItem(
          //           title: const Text(
          //             "Delete",
          //             style: TextStyle(color: Colors.redAccent),
          //           ),
          //           trailingIcon: Icon(
          //             Icons.delete,
          //             color: Colors.redAccent,
          //           ),
          //           onPressed: () {}),
          //     ],
          //     onPressed: () {},
          //     child: Icon(Icons.send),
          //   ),
          // ],
        ),
        body: BlocConsumer(
            bloc: trendingDataBloc,
            listener: (context, state) {
              print('🔄 Trending State Changed: ${state.runtimeType}');

              if (state is TrendingLoadingBeginState) {
                print('🔄 Trending Loading Started');
                // onLoading(context);
                isLoading = true;
              }
              if (state is TrendingErrorState) {
                print('❌ Trending Error State: ${state.exception}');
                // stopLoader(context);
                isLoading = false;
              }
              if (state is GetTrendingState) {
                print('✅ Trending Success State');
                print(
                    '✅ Trending Data Count: ${state.postResponseModel.success?.length ?? 0}');
                // stopLoader(context);
                isLoading = false;
                if (isRefresh) {
                  trendingDataList.clear();
                }

                searchList.clear();
                if (state.postResponseModel.success != null) {
                  for (var element in state.postResponseModel.success!) {
                    // if(element.type == "1"){
                    trendingDataList.add(element);
                    searchList.add(element);
                    // }else if(element.type == "2"){
                    //   storiesDataList.add(element);
                    // }
                  }
                  print(
                      '✅ Trending Data Added - Total: ${trendingDataList.length}');
                } else {
                  print('⚠️ Trending Success State but no data in response');
                }
              }
            },
            builder: (context, _) {
              return Column(
                children: [
                  // Container(
                  //   margin:
                  //       EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       print(
                  //           '🧪 Test button pressed - triggering trending API');
                  //       trendingDataBloc.add(GetTrendingEvent(type: "1"));
                  //     },
                  //     child: Text('Test Trending API'),
                  //   ),
                  // ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.search),
                        title: TextField(
                          controller: controller,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                              hintText: 'Search', border: InputBorder.none),
                          onChanged: onSearchTextChanged,
                        ),
                        trailing: controller.text.trim().isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  controller.clear();
                                  onSearchTextChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  ///trending
                  _buildTrending(),
                ],
              );
            })
        /*RefreshIndicator(
        child: SingleChildScrollView(
          controller: scrollController,
          child:  ///trending
          _buildTrending(),
        ),
        onRefresh: () => _onRefreshHandler(context),
      ),*/
        );
  }

  onSearchTextChanged(String text) async {
    searchList.clear();
    if (text.trim().isEmpty) {
      setState(() {});
      // return;
    }

    if (text.trim().isNotEmpty) {
      for (var userDetail in trendingDataList) {
        if (userDetail.title!
                .toLowerCase()
                .contains(text.trim().toLowerCase()) ||
            userDetail.post!
                .toLowerCase()
                .contains(text.trim().toLowerCase()) ||
            userDetail.userName!
                .toLowerCase()
                .contains(text.trim().toLowerCase())) {
          searchList.add(userDetail);
        }
      }
    } else {
      searchList.addAll(trendingDataList);
    }

    setState(() {});
  }

  getThumbImage(List<ImageData>? images) {
    if (images != null && images.isNotEmpty) {
      if (images.first.filePath != null) {
        return images.first.filePath;
      }
    }
    return "https://media.geeksforgeeks.org/wp-content/uploads/first_run_vscode_gfg.png";
  }

  void pagination() {
    if ((scrollController.position.pixels ==
        scrollController.position.maxScrollExtent)) {
      isRefresh = false;
      currentPageNo = currentPageNo + 1;
      trendingDataBloc.add(GetTrendingEvent(type: "1"));
    }
  }

  Future<void> _onRefreshHandler(BuildContext context) async {
    isRefresh = true;

    ///clear all data and add data from first index.
    trendingDataBloc.add(GetTrendingEvent(type: "1"));
  }

  ///Story json
  void loadData() {
    DefaultAssetBundle.of(context).loadString('assets/json/FacebookPost.json');
  }

  _buildTrending() {
    print(
        '🎨 Building Trending UI - isLoading: $isLoading, searchList.length: ${searchList.length}');

    if (isLoading) {
      print('🎨 Showing Loading State');
      return GestureDetector(
          onTap: () {
            trendingDataBloc.add(GetTrendingEvent(type: "1"));
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
          ));
    } else if (searchList.isNotEmpty) {
      print('🎨 Showing Trending Posts Grid - Count: ${searchList.length}');
      return Expanded(
        child: RefreshIndicator(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0,
            children: List.generate(searchList.length, (index) {
              // print("..................$index");
              return buildItem(searchList[index]);
            }),
          ),
          onRefresh: () => _onRefreshHandler(context),
        ),
      );
      //  ListView.builder(
      //   physics: const NeverScrollableScrollPhysics(),
      //   shrinkWrap: true,
      //   itemBuilder: (BuildContext context, int index) {
      //     return PostWidgets(
      //       name: trendingDataList[index].userName,
      //       //dateTime: postData[index].timestamp!.toDate(),
      //       post: trendingDataList[index].post,
      //       postData: trendingDataList[index],
      //       // imgUrl: getThumbImage(trendingDataList[index].images),
      //       onLike: () {
      //         postBloc.likePost(postId: trendingDataList[index].id!, isFavorite: !trendingDataList[index].isLikedByMe);
      //         trendingDataList[index].isLikedByMe = !trendingDataList[index].isLikedByMe;
      //       },
      //       onFollow: () {
      //         postBloc.followUser(userId: trendingDataList[index].userId!, isFollowed: !trendingDataList[index].isUserFollowedByMe);
      //         trendingDataList[index].isUserFollowedByMe = !trendingDataList[index].isUserFollowedByMe;
      //       },
      //       onSavePost: () {
      //         postBloc.saveToCollection(postId: trendingDataList[index].id!, isFavorite: !trendingDataList[index].isLikedByMe);
      //         trendingDataList[index].isLikedByMe = !trendingDataList[index].isLikedByMe;
      //       },
      //     );
      //   },
      //   itemCount: trendingDataList.length,
      // );
    } else {
      print('🎨 Showing No Data State');
      return GestureDetector(
          onTap: () {
            trendingDataBloc.add(GetTrendingEvent(type: "1"));
          },
          child: const Center(
              child: Text("No data found! Please try again later!!",
                  style: TextStyle(color: Colors.white))));
    }
  }

  buildItem(PostResponseModelData trendingDataList) {
    // String imagePath = isPostImageAvailable(trendingDataList) ? trendingDataList.images?.first.filePath ?? "":"";
    // String videoPath = isPostVideoAvailable(trendingDataList) ? trendingDataList.videos?.first.filePath ?? "":"";

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullScreenPost(
                      postData: trendingDataList,
                      updateData: () {
                        trendingDataBloc.add(GetTrendingEvent(type: "1"));
                      },
                    )));
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => OtherUserProfileScreen(userId: trendingDataList.userId)));
      },
      child: Container(
          width: 90,
          height: 130,
          decoration: BoxDecoration(
            color:
                greyColor, /*
            borderRadius: BorderRadius.all(Radius.circular(20))*/
          ),
          child: getView(trendingDataList)),
    );
  }

  bool isPostImageAvailable(PostResponseModelData trendingDataList) {
    bool isAvailable = false;
    if (trendingDataList.images != null) {
      if (trendingDataList.images?.isNotEmpty ?? false) {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

  bool isPostVideoAvailable(PostResponseModelData trendingDataList) {
    bool isAvailable = false;
    if (trendingDataList.videos != null) {
      if (trendingDataList.videos?.isNotEmpty ?? false) {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

  _buildImageView(PostResponseModelData trendingDataList) {
    return CachedNetworkImage(
      imageUrl: isPostImageAvailable(trendingDataList)
          ? trendingDataList.images!.first.filePath!
          : "",
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(height: 20),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  _buildVideoView(PostResponseModelData trendingDataList) {
    return CachedNetworkImage(
      imageUrl: trendingDataList.thumbUrl ?? "",
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(height: 20),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    // return FutureBuilder(
    //     future: getImagePath(trendingDataList.videos?.first.filePath ?? ""),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData && snapshot.data != null) {
    //         return Image.file(
    //           File("${snapshot.data}"),
    //           fit: BoxFit.cover,
    //         );
    //       } else {
    //         return Container(
    //             width: 96,
    //             height: 96,
    //             color: Colors.transparent,
    //             child: Icon(Icons.error));
    //       }
    //     });
  }

  getView(PostResponseModelData trendingDataList) {
    if (isPostImageAvailable(trendingDataList)) {
      // print("..................image");
      return _buildImageView(trendingDataList);
    } else if (isPostVideoAvailable(trendingDataList)) {
      // print("..................video");
      return _buildVideoView(trendingDataList);
    } else {
      // print("..................nothing");
      return Container(
          width: 96,
          height: 96,
          color: Colors.transparent,
          child: Icon(Icons.error));
    }
  }
}
