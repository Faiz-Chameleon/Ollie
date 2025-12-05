import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/networking/model/response_model/SportInfoModel.dart';
import 'package:octagon/screen/chat_network/bloc/chat_bloc.dart';
import 'package:octagon/screen/common/create_post_controller.dart';
import 'package:octagon/screen/common/create_post_screen.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/screen/mainFeed/home/postController.dart';
import 'package:octagon/screen/profile/other_user_profile.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/polygon/polygon_border.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/src/messages/text_message.dart'
    as textMessage;
import 'package:flutter_chat_types/src/messages/image_message.dart'
    as imageMessage;
import 'package:flutter_chat_types/src/messages/video_message.dart'
    as videoMessage;
import 'package:path_provider/path_provider.dart';
import 'package:resize/resize.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../main.dart';
import '../model/file_upload_response_model.dart';
import '../model/live_score_model.dart';
import '../model/post_response_model.dart';
import '../model/team_list_response.dart';

import '../networking/model/chat_message.dart';
import '../networking/model/chat_replay.dart';
import '../networking/model/chat_room.dart';
import '../networking/model/response_model/team_response_model.dart';
import '../networking/response.dart';
import '../screen/common/full_screen_post.dart';
import '../widgets/default_user_image.dart';
import '../widgets/marquee_text.dart';
import '../widgets/show_selected_image_screen.dart';
import '../widgets/video_editor_screen.dart';
import 'constants.dart';
import 'date_utils.dart';
import 'image_picker_inapp.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SenderData {
  String? senderUid;
  String? senderName;

  SenderData({this.senderName, this.senderUid});
}

class ChatRoomScreen extends StatefulWidget {
  ChatRoom? chatRoom;
  TeamData? sportInfo;

  ChatRoomScreen({this.chatRoom, Key? key, this.sportInfo}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final PostController postController = Get.put(PostController());

  IO.Socket? socket;
  Timer? timer;

  List<Matche> scoreData = [];
  final StreamController<Matche> currentMatch = StreamController<Matche>();

  //FileUploadBloc? fileUploadBloc;
  ScrollController controller = ScrollController();
  // PostBloc postBloc = PostBloc();

  var tmpDate = DateTime.now().add(const Duration(days: 1));

  final ImagePicker _picker = ImagePicker();
  List<PostFile> imageItems = [];
  bool isImage = false;
  String postText = "";

  bool showbtn = false;

  List<types.Message> _messages = [];
  List<bool> isMoreVisible = [];
  List<SenderData> senderData = [];
  // bool isMoreVisible = false;

  types.User? user;

  ChatBloc? bloc;

  // LiveScoreData? liveScoreData;

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Get.snackbar(AppName, "Tap and hold messages to reply!",
    //       snackPosition: SnackPosition.BOTTOM);
    // });

    // fileUploadBloc = FileUploadBloc();
    bloc = ChatBloc();
    // postBloc = PostBloc();

    List<SportInfo> sportInfoData = [];
    var data = storage.read(sportInfo);
    if (data != null) {
      for (var element in (storage.read(sportInfo) as List)) {
        sportInfoData.add(SportInfo.fromJson(element));
      }
    }

    Map<String, dynamic> userDefaultSport = {};
    if (sportInfoData.isNotEmpty) {
      userDefaultSport = sportInfoData.first.toJson();
    }

    user = types.User(
        id: "${storage.read("current_uid")}",
        firstName: "${storage.read("user_name")}",
        imageUrl: "${storage.read("image_url")}",
        lastName: "",
        metadata: userDefaultSport);

    initSocket();

    bloc!.dataStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          if (event.data != null) {
            _messages.clear();
            isMoreVisible.clear();
            senderData.clear();
            event.data!.toList().forEach((element) {
              senderData.add(SenderData(
                  senderName: element.senderName,
                  senderUid: element.senderUid));

              ///adding video data
              if (element.video != null && element.video!.isNotEmpty) {
                isMoreVisible.add(false);

                String docId = element.docId ?? const Uuid().v4();

                _messages.add(types.VideoMessage(
                    author: types.User(
                        id: element.senderUid ?? "",
                        firstName: element.senderName,
                        imageUrl: element.senderImage,
                        lastName: element.senderTeam),
                    createdAt: element.createdOn?.microsecondsSinceEpoch ??
                        DateTime.now().microsecondsSinceEpoch,
                    // height: image.height.toDouble(),
                    id: docId,
                    name: element.content ?? "",
                    // name: ""/*element.video!.substring(
                    //     element.video!.lastIndexOf("-"), element.video!.length)*/,
                    size: 100,
                    uri: element.video!,
                    remoteId: element.image!,

                    ///use remoteId only for video thumb
                    metadata: {
                      "replay": element.replay,
                      "likeCount": element.likeCount,
                      "firebaseToken": element.firebaseToken,
                      "likeUsers": element.likeUsers
                    }

                    ///likecount
                    // width: image.width.toDouble(),
                    ));
              } else if (element.image != null && element.image!.isNotEmpty) {
                ///adding image data
                isMoreVisible.add(false);
                _messages.add(types.ImageMessage(
                    author: types.User(
                        id: element.senderUid ?? "",
                        firstName: element.senderName,
                        imageUrl: element.senderImage,
                        lastName: element.senderTeam),
                    createdAt: element.createdOn?.microsecondsSinceEpoch ??
                        DateTime.now().microsecondsSinceEpoch,
                    // height: image.height.toDouble(),
                    id: element.docId ?? const Uuid().v4(),
                    name: element.content ?? "",
                    size: 100,
                    uri: element.image!,
                    metadata: {
                      "replay": element.replay,
                      "likeCount": element.likeCount,
                      "firebaseToken": element.firebaseToken,
                      "likeUsers": element.likeUsers
                    }
                    // width: image.width.toDouble(),
                    ));
              } else if (element.content != null &&
                  element.content!.isNotEmpty) {
                ///adding text data.
                String message = element.content ?? "";
                isMoreVisible.add(false);
                // if(element.replay!=null && element.replay!.isNotEmpty){
                //   for(ChatReplayMessage value in element.replay!) {
                //     message = "$message \n\n${value.userName}\n${value.content}";
                //   }
                // }
                _messages.add(types.TextMessage(
                    author: types.User(
                        id: element.senderUid ?? "",
                        firstName: element.senderName,
                        imageUrl: element.senderImage,
                        lastName: element.senderTeam),
                    createdAt: element.createdOn?.microsecondsSinceEpoch ??
                        DateTime.now().microsecondsSinceEpoch,
                    id: element.docId ?? const Uuid().v4(),
                    text: message,
                    metadata: {
                      "replay": element.replay,
                      "likeCount": element.likeCount,
                      "firebaseToken": element.firebaseToken,
                      "likeUsers": element.likeUsers
                    }));
              }

              // user = types.User(id: event.data!.first.currentUserUid!);
            });
          }

          // _messages = _messages.reversed.toList();

          for (var element in _messages) {
            if (element.metadata?["replay"] != null &&
                element.metadata?["replay"].isNotEmpty) {
              for (ChatReplayMessage value in element.metadata?["replay"]!) {
                senderData.add(SenderData(
                    senderName: value.userName, senderUid: value.senderUid));
              }
            }
          }

          setState(() {});

          _messages = _messages.reversed.toList();
          for (int i = 0; i < _messages.length; i++) {
            DateTime createdAt =
                DateTime.fromMicrosecondsSinceEpoch(_messages[i].createdAt!);

            var isSameDate = tmpDate.isSameDate(createdAt);

            // Show Date Separator widget if not same date (date changed)
            if (!isSameDate) {
              // Reset tmpDate with current message createdAt date
              tmpDate = createdAt;
            }

            // retrieve timestamp and date String value using Date utility we created in [DateUtil.dart]
            // final date = DateUtil.dateWithDayFormat(createdAt);

            // return true if should show date widget
            bool showDate = !isSameDate;
            _messages[i] = _messages[i].copyWith(showStatus: showDate);
          }

          _messages = _messages.reversed.toList();
          // print(event.data);
          break;
        case Status.ERROR:
          print(Status.ERROR);
          break;
        case null:
        // TODO: Handle this case.
      }
    });

    // postBloc.add(GetLiveScoreEvent());
    bloc!.getChatMessages(widget.chatRoom!, "${storage.read("current_uid")}");

    controller.addListener(() {
      //scroll listener
      double showoffset =
          10.0; //Back to top botton will show on scroll offset 10.0

      if (controller.offset > showoffset) {
        showbtn = true;
        setState(() {
          //update state
        });
      } else {
        showbtn = false;
        setState(() {
          //update state
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  ///init socket in chat
  void initSocket() {
    socket = IO
        .io(
            socketUrl,
            OptionBuilder()
                .setTransports(['websocket']) // for Flutter or Dart VM9
                .disableAutoConnect() // disable auto-connection
                .build())
        .connect();

    socket!.onConnectError((data) {
      print(data);
    });

    socket!.onError((data) {
      print(data);
    });

    socket!.onConnect((value) {
      socket!.connected = true;
      getScore();
    });

    timer =
        Timer.periodic(const Duration(seconds: 10), (Timer t) => getScore());
  }

  ///to get all messages for current room.
  void getScore() {
    Map<String, dynamic> jsonObject = {};
    try {
      List<SportInfo> sportInfoData = [];
      if (storage.read(sportInfo) != null) {
        for (var element in (storage.read(sportInfo) as List)) {
          SportInfo data = SportInfo.fromJson(element);
          sportInfoData.add(SportInfo.fromJson(element));
          if (data.team != null && data.team!.isNotEmpty) {
            jsonObject["sport_id"] = data.id ?? 1;
            break;
          }
        }
      }

      _sendMessage(channelName: "live_score", msgToSend: jsonObject);
    } catch (e) {
      print(e);
    }
  }

  /// retrieve inbox data
  void onMessages() {
    socket!.on('message_received', (messages) {
      print(messages);
    });
  }

  /// send message in socket
  void _sendMessage(
      {required String channelName, required Map<String, dynamic> msgToSend}) {
    if (msgToSend.isNotEmpty) {
      socket!.emitWithAck(channelName, msgToSend, ack: (value) {
        LiveScoreResponseModel data = LiveScoreResponseModel.fromJson(value);
        scoreData = data.matches ?? [];
        updateLiveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        currentPage.add(0);
        return Future(() => true);
      },
      child: StreamBuilder<Matche>(
          stream: currentMatch.stream,
          builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: appBgColor,
              appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: purpleColor,
                flexibleSpace: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Container(
                          decoration: const ShapeDecoration(
                            color: Colors.black,
                            shape: PolygonBorder(
                              sides: 8,
                              rotate: 68,
                              side: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            imageUrl: widget.sportInfo?.strTeamLogo ?? "",
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            width: 50,
                            height: 50,
                            placeholder: (context, url) => const SizedBox(
                                height: 20,
                                child:
                                    Center(child: CircularProgressIndicator())),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              width: 200,
                              child: Text(
                                "${widget.sportInfo?.strTeam} octagon chat room",
                                maxLines: 2,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (snapshot.data?.matchVs != null)
                              SizedBox(
                                width: 240.w,
                                child: MarqueeWidget(
                                  direction: Axis.horizontal,
                                  child: Text(
                                    "Update! ${snapshot.data?.matchVs ?? ''}",
                                    maxLines: 2,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        overflow: TextOverflow.fade),
                                  ),
                                ),
                              ),

                            // Row(
                            //   children: [
                            //     Text(
                            //       "Update! ${currentMatch?.matchVs??''}",
                            //       style: const TextStyle(color: Colors.green, fontSize: 13),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        // const Icon(
                        //   Icons.settings,
                        //   color: Colors.transparent,
                        // ),
                        // buildScoreWidget()
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: Visibility(
                visible: showbtn,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  child: FloatingActionButton(
                    child:
                        const Icon(Icons.arrow_downward, color: Colors.white),
                    mini: true,
                    onPressed: () {
                      controller.animateTo(
                          //go to top of scroll
                          0, //scroll offset to go
                          duration: const Duration(
                              milliseconds: 500), //duration of scroll
                          curve: Curves.fastOutSlowIn //scroll type
                          );
                    },
                  ),
                ),
              ),
              // body: BlocConsumer(
              //     bloc: postBloc,
              //     listener: (context, state) {
              //       // if (state is GetLiveScoreState) {
              //       //   setState(() {
              //       //     liveScoreData = state.liveScoreData;
              //       //   });
              //       // }
              //       if (state is UploadFileState) {
              //         _handleSendPressed(file: state.fileUploadResponseModel.success!, message: postText);
              //       }
              //     },
              //     builder: (context, _) {
              //       return Stack(children: <Widget>[
              //         GestureDetector(
              //           onTap: () {
              //             FocusManager.instance.primaryFocus?.unfocus();
              //           },
              //           child: Container(
              //             margin: const EdgeInsets.only(bottom: 50, top: 50),
              //             child: ListView.builder(
              //               itemCount: _messages.length,
              //               reverse: true,
              //               shrinkWrap: true,
              //               controller: controller,
              //               padding: const EdgeInsets.only(top: 10, bottom: 10),
              //               physics: const AlwaysScrollableScrollPhysics(),
              //               itemBuilder: (context, index) {
              //                 return buildMessageContainer(_messages[index], index);
              //               },
              //             ),
              //           ),
              //         ),
              //         Container(
              //           color: purpleColor,
              //           child: Row(
              //             children: [
              //               IconButton(
              //                 onPressed: () {},
              //                 icon: const Icon(
              //                   Icons.arrow_back,
              //                   color: Colors.transparent,
              //                 ),
              //               ),
              //               const SizedBox(
              //                 width: 66,
              //                 height: 50,
              //               ),
              //               Expanded(
              //                 child: RichText(
              //                   text: TextSpan(children: [
              //                     if (snapshot.data?.startDate != null && getLiveScoreDate("${snapshot.data?.startDate ?? ''}").isNotEmpty)
              //                       const TextSpan(
              //                         style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
              //                         text: "Date: ",
              //                       ),
              //                     if (snapshot.data?.startDate != null && getLiveScoreDate("${snapshot.data?.startDate ?? ''}").isNotEmpty)
              //                       TextSpan(
              //                         style: const TextStyle(color: Colors.green, fontSize: 11),
              //                         text: getLiveScoreDate("${snapshot.data?.startDate ?? ''}"),
              //                       ),
              //                     if (snapshot.data?.startDate != null && getScoreData(snapshot.data!).isNotEmpty)
              //                       const TextSpan(
              //                         style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
              //                         text: "\nScore: ",
              //                       ),
              //                     if (snapshot.data?.startDate != null && getScoreData(snapshot.data!).isNotEmpty)
              //                       TextSpan(
              //                         style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
              //                         text: getScoreData(snapshot.data!),
              //                       ),
              //                   ]),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         _buildMessageArea(),
              //       ]);
              //     }));
              body: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50, top: 50),
                      child: ListView.builder(
                        itemCount: _messages.length,
                        reverse: true,
                        shrinkWrap: true,
                        controller: controller,
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return buildMessageContainer(_messages[index], index);
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: purpleColor,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.transparent,
                          ),
                        ),
                        const SizedBox(
                          width: 66,
                          height: 50,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(children: [
                              if (snapshot.data?.startDate != null &&
                                  getLiveScoreDate(
                                          "${snapshot.data?.startDate ?? ''}")
                                      .isNotEmpty)
                                const TextSpan(
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  text: "Date: ",
                                ),
                              if (snapshot.data?.startDate != null &&
                                  getLiveScoreDate(
                                          "${snapshot.data?.startDate ?? ''}")
                                      .isNotEmpty)
                                TextSpan(
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 11),
                                  text: getLiveScoreDate(
                                      "${snapshot.data?.startDate ?? ''}"),
                                ),
                              if (snapshot.data?.startDate != null &&
                                  getScoreData(snapshot.data!).isNotEmpty)
                                const TextSpan(
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  text: "\nScore: ",
                                ),
                              if (snapshot.data?.startDate != null &&
                                  getScoreData(snapshot.data!).isNotEmpty)
                                TextSpan(
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  text: getScoreData(snapshot.data!),
                                ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMessageArea(),
                ],
              ),
            );
          }),
    );
  }

  _buildMessageArea() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
        // height: 60,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                ///open image picker dialog and then upload image then
                ///open image viewer screen with Edit text for comment message.
                buildImagePickerDialog();
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 10,
                controller: messageController,
                decoration: const InputDecoration(
                    hintText: "Write message...",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            GestureDetector(
              onTap: () {
                _handleSendPressed(message: messageController.text.trim());
              },
              child: Container(
                height: 38,
                width: 38,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _displayTextInputDialog(BuildContext context, String msg,
      {String name = ""}) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: RichText(
              text: TextSpan(
                  text: name,
                  style: greyColor16TextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  children: [
                    TextSpan(
                      text: msg,
                      style: greyColor14TextStyle.copyWith(color: Colors.black),
                    )
                  ]),
            ),
            content: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              onSubmitted: (_) {
                Navigator.pop(context, true);
              },
              decoration:
                  const InputDecoration(hintText: "add your message here.."),
            ),
            actions: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    // _textFieldController.text = "";
                    Navigator.pop(context, false);
                  });
                },
                child: Container(
                  // color: Colors.red,
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.pop(context, true);
                  });
                },
                child: Container(
                  // color: Colors.green,
                  padding: const EdgeInsets.all(5),
                  child: const Text('reply',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          );
        }).then((value) {
      return value;
    });
  }

  Widget buildMessageContainer(types.Message message, int index) {
    int depth = 1;

    // textMessage.TextMessage data =
    // textMessage.TextMessage.fromJson(message.toJson());

    List<ChatReplayMessage> replayData = [];
    if (message.metadata?["replay"] != null &&
        message.metadata?["replay"].isNotEmpty) {
      for (ChatReplayMessage value in message.metadata?["replay"]!) {
        replayData.add(value);
        // message = "$message \n\n${value.userName}\n${value.content}";
      }
    }

    return Container(
      // decoration: const BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       color: Colors.white,
      //       width: 0.05,
      //     ),
      //   ),
      // ),
      padding: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 0),
      child: Align(
        alignment: Alignment
            .topLeft /*(data.author.id != user!.id
            ? Alignment.topLeft
            : Alignment.topRight)*/
        ,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start /*data.author.id == user!.id ? CrossAxisAlignment.end : CrossAxisAlignment.start*/,
            children: [
              // show Date Separator widget if True

              Visibility(
                visible: message.showStatus ?? false,
                replacement: Container(height: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.white,
                      width: 120,
                      height: 1,
                    ),
                    Container(
                      height: 15,
                      color: Colors.green[50],
                      child: Text(
                        DateUtil.dateWithDayFormat(
                            DateTime.fromMicrosecondsSinceEpoch(
                                message.createdAt!)),
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      width: 120,
                      height: 1,
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OtherUserProfileScreen(
                                  userId: int.parse(message.author.id))));
                    },
                    child: Stack(
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 85,
                        ),
                        Container(
                            width: 50,
                            height: 65,
                            decoration: BoxDecoration(
                                color: greyColor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        message.author.imageUrl ?? ""),
                                    fit: BoxFit.cover)),
                            child:
                                !isProfilePicAvailable(message.author.imageUrl)
                                    ? defaultThumb()
                                    : null),
                        Positioned(
                          top: 42,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 35,
                            width: 30,
                            decoration: const ShapeDecoration(
                              color: Colors.black,
                              shape: PolygonBorder(
                                sides: 8,
                                rotate: 68,
                                side: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: message.author.lastName ?? "",
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              height: 30,
                              width: 30,
                              placeholder: (context, url) =>
                                  const SizedBox(height: 20),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () {
                      _displayTextInputDialog(
                              context, message.author.firstName ?? "")
                          .then((value) {
                        if (messageController.text.trim().isNotEmpty && value) {
                          _handleSendPressed(
                              message: messageController.text.trim(),
                              isReplay: true,
                              replayTo: message.author.id,
                              firebaseToken: message.metadata?["firebaseToken"],
                              userNameForNotification: message.author.firstName,
                              oldMessage: message);
                        } else {
                          messageController.clear();
                        }
                      });
                    },
                    onDoubleTap: () {
                      _handleSendPressed(
                          message: messageController.text.trim(),
                          isReplay: true,
                          replayTo: message.author.id,
                          oldMessage: message,
                          isLike: true);
                      /*_displayTextInputDialog(
                              context, message.author.firstName ?? "")
                          .then((value) {
                        if (messageController.text.trim().isNotEmpty) {
                          _handleSendPressed(message: messageController.text.trim(),
                              isReplay: true,
                              replayTo: message.author.id,
                              oldMessage: message);
                        }
                      });*/
                    },
                    child: Container(
                      // width: 300,
                      constraints:
                          const BoxConstraints(minWidth: 100, maxWidth: 310),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        // color: (data.author.id != user!.id
                        //     ? Colors.grey.shade200
                        //     : Colors.blue[200]),
                      ),
                      padding: const EdgeInsets.only(left: 16),
                      child: buildMessageView(message),
                    ),
                  ),
                ],
              ),
              // Dash(
              //     direction: Axis.horizontal,
              //     length: 350,
              //     dashLength: 1,
              //     dashThickness: 0.1,
              //     dashColor: Colors.white),
              ListView.builder(
                itemCount: !isMoreVisible[index] && replayData.length > 3
                    ? 3
                    : replayData.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, indexxx) {
                  ChatReplayMessage value = replayData[indexxx];

                  return replayMessageContainer(value,
                      isLast: replayData.length == indexxx,
                      message: message,
                      depthCount: depth,
                      docId: value.docId,
                      isMoreVisibleIndex: index);
                },
              ),
              Visibility(
                visible: replayData.length > 3,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isMoreVisible[index] = !isMoreVisible[index];
                      });
                    },
                    child: Text(
                      "Show " + (isMoreVisible[index] ? 'Less' : 'More'),
                      style: const TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getDateTime(int? createdAt) {
    String value = DateFormat('hh:mm a').format((createdAt != null
        ? Timestamp.fromMicrosecondsSinceEpoch(createdAt).toDate()
        : DateTime.now()));
    return value;
    // return (createdAt!=null ?Timestamp.fromMicrosecondsSinceEpoch(createdAt).toDate() : DateTime.now()).timeAgo(numericDates: false);
  }

  // buildScoreWidget() {
  //   return Visibility(
  //     visible: liveScoreData != null,
  //     // replacement: const Text("No game running!",
  //     //   style: TextStyle(
  //     //       color: Colors.white,
  //     //       fontSize: 16, fontWeight: FontWeight.w600),
  //     // ),
  //     child: Column(
  //       children: [
  //         Text(
  //           "Live score Data",
  //           // widget.sportInfo?.strSport ?? "",
  //           style: const TextStyle(
  //               color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
  //         )
  //       ],
  //     ),
  //   );
  // }
  void buildImagePickerDialog() async {
    final ImageSource? imageSource = await showImagePicker(context);

    if (!mounted || imageSource == null && imageSource != null) return;

    try {
      imageItems = [];
      isImage = false;

      if (imageSource == null) {
        // User selected "Video"
        final pickedFile = await _picker.pickVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(seconds: 120));
        if (pickedFile?.path != null) {
          isImage = false;
          imageItems.add(PostFile(filePath: pickedFile!.path, isVideo: true));
        }
      } else if (imageSource == ImageSource.camera) {
        final pickedFile =
            await _picker.pickImage(source: imageSource, imageQuality: 50);
        if (pickedFile?.path != null) {
          isImage = true;
          imageItems.add(PostFile(filePath: pickedFile!.path, isVideo: false));
        }
      } else {
        final pickedFileList = await _picker.pickMultiImage();
        isImage = true;
        imageItems.addAll(
          pickedFileList.map((e) => PostFile(filePath: e.path, isVideo: false)),
        );
      }

      if (imageItems.isEmpty) return;

      if (!isImage) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => VideoEditor(file: File(imageItems[0].filePath))),
        );
        if (result != null) {
          openSelectedFile([result], isImage);
        }
      } else {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageEditor(
              image: File.fromUri(Uri.file(imageItems[0].filePath))
                  .readAsBytesSync(),
              savePath: Directory.fromUri(Uri.file(imageItems[0].filePath))
                  .toString(),
            ),
          ),
        );
        if (result != null) {
          saveImage(result).then((savedPath) {
            if (savedPath != null) openSelectedFile([savedPath], isImage);
          });
        }
      }
    } catch (e) {
      print('Image Picker Error: $e');
    }
  }

  Future<String?> saveImage(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'edited_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      print("Error saving image: $e");
      return null;
    }
  }

  // buildImagePickerDialog() {
  //   showImagePicker(context, onImageSelection: (ImageSource? imageSource) async {
  //     try {
  //       imageItems = [];
  //       isImage = false;

  //       if (imageSource == null) {
  //         final pickedFileList = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 120));
  //         if (pickedFileList?.path != null) {
  //           isImage = false;
  //           imageItems.add(PostFile(filePath: pickedFileList!.path, isVideo: !isImage));
  //         }
  //       } else if (imageSource == ImageSource.camera) {
  //         final pickedFileList = await _picker.pickImage(source: imageSource!, imageQuality: 50);
  //         if (pickedFileList?.path != null) {
  //           isImage = true;
  //           imageItems.add(PostFile(filePath: pickedFileList!.path, isVideo: !isImage));
  //         }
  //       } else {
  //         final pickedFileList = await _picker.pickMultiImage();
  //         pickedFileList.map((file) => file.path).toList();
  //         isImage = true;
  //         pickedFileList.forEach((element) {
  //           imageItems.add(PostFile(filePath: element.path, isVideo: !isImage));
  //         });
  //       }

  //       if (imageItems.isNotEmpty) {
  //         if (mounted) {
  //           if (!isImage) {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (BuildContext context) => VideoEditor(file: File(imageItems[0].filePath)),
  //               ),
  //             ).then((value) {
  //               if (value != null) {
  //                 // String thumbUrl = "";
  //                 // const platformChannel = MethodChannel('thumber');
  //                 try {
  //                   openSelectedFile([value], isImage);
  //                   // genThumbnailFile(value).then((thumbUrl) {
  //                   //   openSelectedFile([value, thumbUrl!=null?thumbUrl.path:""], isImage);
  //                   // });
  //                   // platformChannel
  //                   //     .invokeMethod('getThumbFromUrl', <String, dynamic>{
  //                   //   'videoUrl': value,
  //                   //   'isLocal': true,
  //                   // }).then((thumbByte) async {
  //                   //   thumbUrl = await saveImage(thumbByte);
  //                   //
  //                   //   openSelectedFile([value, thumbUrl], isImage);
  //                   // });
  //                 } on PlatformException catch (e) {
  //                   print(e);
  //                 }
  //               }
  //             });
  //           } else {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => ImageEditor(
  //                   image: File.fromUri(Uri.file(imageItems[0].filePath)).readAsBytesSync(), // <-- Uint8List of image
  //                   // allowCamera: false,
  //                   // allowGallery: false,
  //                   savePath: Directory.fromUri(Uri.file(imageItems[0].filePath.toString())).toString(),
  //                   // appBarColor: Colors.blue,
  //                   // bottomBarColor: Colors.blue,
  //                 ),
  //               ),
  //             ).then((value) {
  //               if (value != null) {
  //                 saveImage(value).then((value) {
  //                   // onImagePicker([value], !isImage);
  //                   openSelectedFile([value], isImage);
  //                 });
  //               }
  //             });
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   });
  // }

  Future<File?> genThumbnailFile(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      // maxHeight: 100, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );
    if (fileName != null) {
      File file = File(fileName);
      return file;
    }
    return null;
  }

  void _handleSendPressed(
      {String message = "",
      bool isReplay = false,
      String replayTo = "",
      types.Message? oldMessage,
      SucessData? file,
      String? docId,
      int depthCount = 0,
      bool isLike = false,
      String? firebaseToken,
      String? userNameForNotification}) {
    messageController.text = "";
    postText = "";

    ChatMessageData chatMessage = ChatMessageData(
        content: message,
        senderUid: "${storage.read("current_uid")}",
        firebaseToken: storage.read("fcm_token"));

    if (file != null) {
      // if (file.latest == null) {
      //   return;
      // }
      if (isImage) {
        chatMessage.image = file.filePath;
      } else {
        chatMessage.video = file.filePath;
        chatMessage.image = file.thumbUrl;
      }
    }

    if (oldMessage != null) {
      chatMessage.senderName = oldMessage.author.firstName;
      chatMessage.senderUid = oldMessage.author.id;
      chatMessage.firebaseToken = oldMessage.metadata!["firebaseToken"];
      chatMessage.docId = oldMessage.id;
      chatMessage.replay = oldMessage.metadata!["replay"];
      chatMessage.likeUsers = oldMessage.metadata?["likeUsers"] ?? [];

      if (isLike && docId == null) {
        chatMessage.likeUsers ??= [];
        if (chatMessage.likeUsers!.indexWhere(
                (element) => element == "${storage.read("current_uid")}") ==
            -1) {
          chatMessage.likeUsers!.add("${storage.read("current_uid")}");
          chatMessage.likeCount = oldMessage.metadata!["likeCount"] != null
              ? oldMessage.metadata!["likeCount"] + 1
              : 1;

          ///likecount
        } else {
          // showToast(message: "You have already like this!");
          chatMessage.likeUsers!.removeWhere(
              (element) => element == "${storage.read("current_uid")}");
          chatMessage.likeCount = oldMessage.metadata!["likeCount"] != null
              ? oldMessage.metadata!["likeCount"] - 1
              : null;

          ///likecount

          if (chatMessage.likeCount == 0) {
            chatMessage.likeCount = null;
          }
          // return;
        }
      } else {
        chatMessage.likeCount = oldMessage.metadata!["likeCount"];
      }

      chatMessage.senderImage = oldMessage.author.imageUrl;

      ///user image
      chatMessage.senderTeam = oldMessage.author.lastName;

      ///team logo

      oldMessage = types.TextMessage(
        author: oldMessage.author,
        createdAt: oldMessage.createdAt,
        id: oldMessage.id,
        text: message,
      );
    } else {
      oldMessage = types.TextMessage(
        author: user!,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message,
      );

      chatMessage.senderImage = user?.imageUrl ?? "";

      ///user image
      chatMessage.senderTeam =
          user?.lastName ?? "${storage.read("userDefaultTeam")}" ?? "";
      if (user != null) {
        if (user!.lastName!.isNotEmpty) {
          chatMessage.senderTeam = user?.lastName;
        }
        chatMessage.senderTeam = "${storage.read("userDefaultTeam")}";
      }

      ///team logo
      chatMessage.senderName = user?.firstName ?? "";
    }

    if (isReplay) {
      // if(_messages.contains((element) => element.id == oldMessage!.id)){
      //   // _messages.
      // }

      ChatReplayMessage data = ChatReplayMessage(
        content: message,
        docId: const Uuid().v4(),
        senderUid: "${storage.read("current_uid")}",
        firebaseToken: "${storage.read("fcm_token")}",
        userName: "${storage.read("user_name")}",
        userDefaultTeam: "${storage.read("userDefaultTeam")}",
        userImage: "${storage.read("image_url")}",
        createdAt: DateTime.now().microsecondsSinceEpoch,
      );

      if ((chatMessage.replay == null || chatMessage.replay!.isEmpty) &&
          !isLike) {
        chatMessage.replay = [];
      }

      if (docId != null) {
        if (depthCount > 1) {
          data.content = "@$replayTo ${data.content}";

          if (isLike) {
            data.likeUsers ??= [];
            if (data.likeUsers!.indexWhere(
                    (element) => element == "${storage.read("current_uid")}") !=
                -1) {
              data.likeUsers!.add("${storage.read("current_uid")}");

              data.likeCount = data.likeCount != null ? data.likeCount! + 1 : 1;

              ///likecount
            } else {
              // showToast(message: "You have already like this!");
              data.likeUsers!.removeWhere(
                  (element) => element == "${storage.read("current_uid")}");
              data.likeCount =
                  data.likeCount != null ? data.likeCount! - 1 : 0; //
              if (data.likeCount == 0) {
                data.likeCount = null;
              }
              // return;
            }
          }
        }
        // if(chatMessage.replay!=null && chatMessage.replay!.isNotEmpty){
        //   for (var i = 0; i < chatMessage.replay!.length; i++){
        //     if(chatMessage.replay![i].docId == docId){
        //       chatMessage.replay![i].replay!.add(data);
        //       break;
        //     }
        //   }
        //   // chatMessage.replay!.firstWhere((element) => element.docId == docId).replay!.add(data);
        // }
        if (!isLike) {
          chatMessage.replay!.add(data);
        } else {
          if (chatMessage.replay != null && chatMessage.replay!.isNotEmpty) {
            int likeCounts = chatMessage.replay!
                    .firstWhere((element) => element.docId == docId)
                    .likeCount ??
                0;
            ChatReplayMessage valueData = chatMessage.replay!
                .firstWhere((element) => element.docId == docId);

            // valueData.likeCount = likeCounts + 1;

            valueData.likeUsers ??= [];
            if (valueData.likeUsers!.indexWhere(
                    (element) => element == "${storage.read("current_uid")}") ==
                -1) {
              valueData.likeUsers!.add("${storage.read("current_uid")}");
              valueData.likeCount = likeCounts + 1;

              ///likecount
            } else {
              // showToast(message: "You have already like this!");

              valueData.likeUsers!.removeWhere(
                  (element) => element == "${storage.read("current_uid")}");
              valueData.likeCount = likeCounts - 1;

              ///likecount

              if (valueData.likeCount == 0) {
                valueData.likeCount = null;
              }
              // return;
            }
          }
        }
      } else {
        if (!isLike) {
          chatMessage.replay!.add(data);
        }
      }

      bloc!.sendReplayMessage(chatMessage, widget.chatRoom!.id!);
    } else {
      bloc!.sendMessage(chatMessage, widget.sportInfo!);
      // bloc!.sendReplayMessage(chatMessage, widget._chatRoom.id!, replayTo: replayTo);
    }

    ///send firebase push notification
    if (firebaseToken != null) {
      bloc!.sendNotifications(
          token: firebaseToken,
          description:
              "$userNameForNotification ${isLike ? 'like' : 'reply'} your message",
          subject: "");
    }

    if (!isLike) {
      _addMessage(oldMessage);
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  String getUserName(String s) {
    try {
      if (s.contains("@")) {
        String name = senderData
                .firstWhere((element) =>
                    element.senderUid == s.substring(1, s.indexOf(" ")))
                .senderName ??
            "";

        return "@$name ";
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  void openSelectedFile(List<String> list, bool isImage) async {
    ///open selected image in new screen.
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectedImageScreen(
                  imageItems: list,
                  isVideo: !isImage,
                  postText: postText,
                ))).then((value) async {
      // print(value);
      if (value != null) {
        imageItems = [];
        postText = value[2] ?? "";
        isImage = (value[0] ?? true);

        if (!isImage) {
          imageItems
              .add(PostFile(filePath: (value[1] as List).first, isVideo: true));
          imageItems
              .add(PostFile(filePath: (value[1] as List).last, isVideo: false));
        } else {
          imageItems.add(
              PostFile(filePath: (value[1] as List).first, isVideo: !isImage));
        }

        if (imageItems.isNotEmpty) {
          // onImagePicker(imageItems);
          ///call upload file api from here
          //fileUploadBloc!.uploadFile(files: imageItems, postType: isImage?0:1);
          // postBloc.add(UploadFileEvent(postType: isImage ? 0 : 1, files: imageItems));
          // postController.uploadMedia(isImage ? 0 : 1, imageItems).then((res) {
          //   if (res != null) {
          //     _handleSendPressed(file: res.success, message: postText);
          //   }
          // });v
          final result =
              await postController.uploadMedia(isImage ? 0 : 1, imageItems);
          if (result != null) {
            _handleSendPressed(file: result.success, message: postText);
          }
        }
      }
    });
  }

  replayMessageContainer(ChatReplayMessage value,
      {required bool isLast,
      types.Message? message,
      required int depthCount,
      String? docId,
      required int isMoreVisibleIndex}) {
    depthCount++;

    // print(docId);
    List<ChatReplayMessage> replayData = value.replay ?? [];
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 5),
      child: Align(
        alignment: Alignment
            .topLeft /*(value.senderUid != user!.id
            ? Alignment.topLeft
            : Alignment.topRight)*/
        ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // color: Colors.green,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OtherUserProfileScreen(
                                  userId: int.parse(value.senderUid!))));
                    },
                    child: Stack(
                      children: [
                        // Visibility(
                        //   visible: !isLast,
                        //   child: const SizedBox(
                        //     width: 50,
                        //     child: Dash(
                        //         direction: Axis.vertical,
                        //         length: 100,
                        //         dashLength: 1,
                        //         dashColor: Colors.white),
                        //   ),
                        // ),
                        const SizedBox(
                          width: 40,
                          height: 55,
                        ),
                        Container(
                            width: 40,
                            height: 45,
                            decoration: BoxDecoration(
                                color: greyColor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                image: DecorationImage(
                                    image: NetworkImage(value.userImage ?? ""),
                                    fit: BoxFit.cover)),
                            child: !isProfilePicAvailable(value.userImage)
                                ? defaultThumb()
                                : null),
                        Positioned(
                          top: 32,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 25,
                            width: 20,
                            decoration: const ShapeDecoration(
                              color: Colors.black,
                              shape: PolygonBorder(
                                sides: 8,
                                rotate: 68,
                                side: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: value.userDefaultTeam ?? "",
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              width: 20,
                              height: 20,
                              placeholder: (context, url) =>
                                  const SizedBox(height: 20),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () {
                      _displayTextInputDialog(context, " ${value.content}",
                              name: value.userName ?? "")
                          .then((data) {
                        if (messageController.text.trim().isNotEmpty && data) {
                          _handleSendPressed(
                              message: messageController.text.trim(),
                              isReplay: true,
                              replayTo: value.senderUid!,
                              firebaseToken: value.firebaseToken,
                              userNameForNotification: value.userName,
                              oldMessage: message,
                              docId:
                                  docId /*depthCount > 2 ? docId : value.docId*/,
                              depthCount: depthCount);
                        } else {
                          messageController.clear();
                        }
                      });
                    },
                    onDoubleTap: () {
                      // print("double tap chat message 767");
                      _handleSendPressed(
                          message: messageController.text.trim(),
                          isReplay: true,
                          replayTo: value.senderUid!,
                          firebaseToken: value.firebaseToken,
                          userNameForNotification: value.userName,
                          oldMessage: message,
                          docId: docId /*depthCount > 2 ? docId : value.docId*/,
                          depthCount: depthCount,
                          isLike: true);
                      /*_displayTextInputDialog(context, "${value.userName??""} ${value.content}").then((data) {
                        if(messageController.text.trim().isNotEmpty){
                          _handleSendPressed(message: messageController.text.trim(),
                              isReplay: true,
                              replayTo: value.senderUid!,
                              oldMessage: message, docId: docId*/ /*depthCount > 2 ? docId : value.docId*/ /*,
                              depthCount: depthCount);
                        }
                      });*/
                      // _displayTextInputDialog(context, data.author.firstName??"").then((value) {
                      //   if(messageController.text.trim().isNotEmpty){
                      //     _handleSendPressed(messageController.text.trim(), isReplay: true, replayTo: data.id, oldMessage: data);
                      //   }
                      // });
                    },
                    child: Container(
                      // width: 300,
                      constraints:
                          const BoxConstraints(minWidth: 100, maxWidth: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        // color: (value.senderUid != user!.id
                        //     ? Colors.grey.shade200
                        //     : Colors.green[200]),
                      ),
                      padding:
                          const EdgeInsets.only(left: 16, bottom: 5, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${value.userName}".capitalize!,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              RichText(
                                text: TextSpan(
                                    text:
                                        "${getDateTime(value.createdAt ?? message!.createdAt!)} \n",
                                    style: chatTimeTextStyle,
                                    children: [
                                      if (value.likeCount != null)
                                        WidgetSpan(
                                            child: Transform.translate(
                                                offset: const Offset(0.0, 7.0),
                                                child: likeCountWidget(
                                                    likeCount:
                                                        value.likeCount!))),
                                    ]),
                              ),
                            ],
                          ),
                          RichText(
                            text: TextSpan(
                                text: getUserName(value.content ?? ''),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue.withOpacity(0.8)),
                                children: [
                                  TextSpan(
                                    text:
                                        "${isReplyMessage(value.content ?? "") ? getMessageContent(value.content ?? "") : value.content ?? ""} ",
                                    style: whiteColor16TextStyle,
                                  ),
                                ]),
                          ),
                          // Text(
                          //   getUserName(value.content ?? ""),
                          //   overflow: TextOverflow.clip,
                          //   style: const TextStyle(fontSize: 15, color: Colors.green),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              itemCount: !isMoreVisible[isMoreVisibleIndex] &&
                      value.replay != null &&
                      value.replay!.length > 3
                  ? 3
                  : replayData.length,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                ChatReplayMessage value = replayData[index];

                return replayMessageContainer(value,
                    isLast: replayData.length == index,
                    message: message,
                    depthCount: depthCount,
                    docId: docId,
                    isMoreVisibleIndex: 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  buildMessageView(types.Message message) {
    // data.type
    if (message.type == types.MessageType.image) {
      return buildImageView(message);
    } else if (message.type == types.MessageType.video) {
      return buildVideoView(message);
    }

    textMessage.TextMessage data =
        textMessage.TextMessage.fromJson(message.toJson());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${message.author.firstName}".capitalize!,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white),
                ),
              ],
            ),
            SizedBox(
              width: 220,
              child: Text(
                "${data.text ?? ''}",
                overflow: TextOverflow.clip,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        ),
        RichText(
          text: TextSpan(
              text: "${getDateTime(message.createdAt!)} \n",
              style: chatTimeTextStyle,
              children: [
                if (data.metadata?["likeCount"] != null)
                  WidgetSpan(
                      child: Transform.translate(
                          offset: Offset(0.0, 7.0),
                          child: likeCountWidget(
                              likeCount: data.metadata?["likeCount"] ?? 0))),
              ]),
        ),
      ],
    );
  }

  buildVideoView(types.Message message) {
    videoMessage.VideoMessage data =
        videoMessage.VideoMessage.fromJson(message.toJson());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${message.author.firstName}".capitalize!,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
              text: "${data.name}",
              style: greyColor14TextStyle.copyWith(
                color: Colors.white,
              )),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                PostResponseModelData value = PostResponseModelData(
                  /*id: data.id,*/
                  title: data.name,
                  comments: [],
                  userId: int.tryParse(data.author.id) ?? 0,
                  userName: data.author.firstName,
                  type: "1",
                  images: [],
                  photo: data.author.imageUrl,
                  sportInfo: [
                    SportInfo(strSportThumb: data.author.imageUrl, team: [
                      TeamResponseModel(strTeamLogo: data.author.lastName)
                    ])
                  ],
                  videos: [
                    ImageData(filePath: data.uri ?? "")
                  ], /*createdAt:  data.author.*/
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullScreenPost(
                              isFromChat: true,
                              postData: value,
                              updateData: () {},
                              // [data.uri],
                              // initialIndex: 0,
                              // isVideo: true,
                              // message: value,
                              // title: "${data.author.firstName}",
                            )));
              },
              onDoubleTap: () {
                _handleSendPressed(
                    message: '',
                    isReplay: true,
                    replayTo: message.author.id,
                    firebaseToken: message.metadata?["firebaseToken"],
                    userNameForNotification: message.author.firstName,
                    oldMessage: message,
                    isLike: true);
              },
              child: Container(
                // height: 250,
                width: 250,
                alignment: Alignment.topLeft,
                color: Colors.white,
                child: Stack(
                  children: [
                    Align(
                        child: CachedNetworkImage(
                          imageUrl: getThumbUrl(data),
                          fit: BoxFit.cover,
                          // width: 250,
                          // height: 250,
                          alignment: Alignment.center,
                          // placeholder: (context, url) => const SizedBox(height: 20),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        alignment: Alignment.center),
                    Positioned(
                      child:
                          Icon(Icons.play_circle, color: appBgColor, size: 28),
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              child: RichText(
                text: TextSpan(
                    text: "${getDateTime(message.createdAt!)} \n",
                    style: chatTimeTextStyle,
                    children: [
                      if (message.metadata?["likeCount"] != null)
                        WidgetSpan(
                            child: Transform.translate(
                                offset: Offset(0.0, 7.0),
                                child: likeCountWidget(
                                    likeCount:
                                        message.metadata?['likeCount'] ?? 0))),
                    ]),
              ),
            )
          ],
        ),
      ],
    );
  }

  buildImageView(types.Message message) {
    imageMessage.ImageMessage data =
        imageMessage.ImageMessage.fromJson(message.toJson());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${message.author.firstName}".capitalize!,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: RichText(
            maxLines: 10,
            textAlign: TextAlign.start,
            overflow: TextOverflow.clip,
            text: TextSpan(
                text: data.name ?? "",
                style: greyColor14TextStyle.copyWith(
                  color: Colors.white,
                  // fontSize: 13,
                )),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                PostResponseModelData? postData;
                Function? updateData;
                // FullScreenPost
                PostResponseModelData value = PostResponseModelData(
                  /*id: data.id,*/
                  title: data.name,
                  comments: [],
                  userId: int.tryParse(data.author.id) ?? 0,
                  userName: data.author.firstName,
                  type: "1",
                  photo: data.author.imageUrl,
                  images: [ImageData(filePath: data.uri ?? "")],
                  sportInfo: [
                    SportInfo(strSportThumb: data.author.imageUrl, team: [
                      TeamResponseModel(strTeamLogo: data.author.lastName)
                    ])
                  ],
                  videos: [], /*createdAt:  data.author.*/
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullScreenPost(
                              isFromChat: true,
                              postData: value,
                              updateData:
                                  () {}, /*GalleryPhotoViewWrapper(
                              [data.uri],
                              initialIndex: 0,
                              message: value,
                              title: "${data.author.firstName}",*/
                            )));
              },
              onDoubleTap: () {
                _handleSendPressed(
                    message: messageController.text.trim(),
                    isReplay: true,
                    replayTo: message.author.id,
                    firebaseToken: message.metadata?["firebaseToken"],
                    userNameForNotification: message.author.firstName,
                    oldMessage: message,
                    isLike: true);
              },
              child: Container(
                width: 250,
                alignment: Alignment.topLeft,
                color: Colors.black,
                padding: const EdgeInsets.only(top: 10),
                // clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: data.uri ?? "",
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  // placeholder: (context, url) => const SizedBox(height: 20),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Flexible(
              child: RichText(
                text: TextSpan(
                    text: "${getDateTime(message.createdAt!)} \n",
                    style: chatTimeTextStyle,
                    children: [
                      if (message.metadata?["likeCount"] != null)
                        WidgetSpan(
                            child: Transform.translate(
                                offset: Offset(0.0, 7.0),
                                child: likeCountWidget(
                                    likeCount:
                                        message.metadata?['likeCount'] ?? 0))),
                    ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String getThumbUrl(types.VideoMessage data) {
    if (data.remoteId != null && data.remoteId!.isNotEmpty) {
      return data.remoteId ?? "";
    } else {
      return "";
    }
  }

  Widget likeCountWidget({required int likeCount}) {
    return RichText(
      text: TextSpan(
          text: "\u2764️",
          style: chatTimeTextStyle.copyWith(),
          children: [
            TextSpan(
              text: " $likeCount️",
              style:
                  chatTimeTextStyle.copyWith(fontSize: 12, color: Colors.white),
            )
          ]),
    );
  }

  void updateLiveData() {
    setState(() {
      Matche? value = scoreData.firstWhereOrNull((element) => element.matchVs!
          .toLowerCase()
          .contains((widget.sportInfo?.strTeam ?? '').toLowerCase()));
      if (value != null) {
        currentMatch.add(value);
      }
    });
  }

  String getScoreData(Matche currentMatch) {
    String score = "";
    if (currentMatch.matchTeams != null &&
        currentMatch.matchTeams!.isNotEmpty) {
      MatchTeam? firstTeam = currentMatch.matchTeams?.first;

      if (firstTeam != null) {
        ///first team name.
        score = firstTeam.teamName ?? "";

        if (firstTeam.matchScore != null && firstTeam.matchScore!.isNotEmpty) {
          MatchScore? lastScore = firstTeam.matchScore?.last;

          ///latest score of first team.
          ///first team score.
          if (lastScore != null) {
            score = "$score ${lastScore.score ?? "0"}";
          } else {
            score = "$score 0";
          }
        } else {
          score = "$score 0";
        }
      }

      MatchTeam? secondTeam = currentMatch.matchTeams?.last;

      if (secondTeam != null) {
        ///second team name.
        score = "$score ${secondTeam.teamName ?? ""}";

        if (secondTeam.matchScore != null &&
            secondTeam.matchScore!.isNotEmpty) {
          MatchScore? lastScore = secondTeam.matchScore?.last;

          ///latest score of second team.
          ///second team score.
          if (lastScore != null) {
            score = "$score ${lastScore.score ?? "0"}";
          } else {
            score = "$score 0";
          }
        } else {
          score = "$score 0";
        }
      }
    }

    return score.trim();
  }

  String getLiveScoreDate(String dateTime) {
    if (dateTime.isNotEmpty) {
      var date = DateFormat("yyyy-MM-dd HH:mm").parse(dateTime, true);
      var dateLocal = date.toLocal();
      var outputFormat = DateFormat('MMM d, h:mm a');
      var outputDate = outputFormat.format(dateLocal);

      return outputDate.toString();
    } else {
      return "";
    }
  }
}

getMessageContent(String s) {
  try {
    if (s.contains(" ")) {
      String name = s.substring(s.indexOf(" "));

      return name;
    } else {
      return s;
    }
  } catch (e) {
    return s;
  }
}

bool isReplyMessage(String s) {
  try {
    return s.contains("@");
  } catch (e) {
    return false;
  }
}

bool isProfilePicAvailable(String? url) {
  if (url == null || url.contains("null") || url.isEmpty) {
    return false;
  } else {
    return true;
  }
}
