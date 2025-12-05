import 'dart:async';
import 'package:resize/resize.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../model/live_score_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme/theme_constants.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  IO.Socket? socket;
  Timer? timer;

  List<Matche> scoreData = [];

  @override
  void initState() {
    initSocket();
    super.initState();
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
      jsonObject["sport_id"] = 1;

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
        print(value);
        LiveScoreResponseModel data = LiveScoreResponseModel.fromJson(value);
        print(data);

        setState(() {
          scoreData = data.matches ?? [];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Score Board",
          style: whiteColor20BoldTextStyle,
        ),
      ),
      body: SafeArea(
          child: ListView.builder(
              padding: EdgeInsets.all(2.w),
              itemCount: scoreData.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(bottom: 2.w, top: 0.5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scoreData[index].matchVs ?? '',
                        maxLines: 2,
                        style: const TextStyle(color: Colors.green),
                        overflow: TextOverflow.clip,
                      ),
                      // Text(
                      //   getScoreData(scoreData[index]),
                      //   maxLines: 2,
                      //   style: const TextStyle(color: Colors.white),
                      //   overflow: TextOverflow.clip,
                      // )
                    ],
                  ),
                );
              })),
    );
  }

  String getScoreData(Matche scoreData) {
    if(scoreData.matchTeams!=null){
     if(scoreData.matchTeams?.first!=null) {
       if (scoreData.matchTeams?.first.matchScore != null &&
           scoreData.matchTeams?.first.matchScore!.first!=null) {
         if (scoreData.matchTeams?.first.matchScore?.first.innings != null){
           return scoreData.matchTeams?.first.matchScore?.first.innings??"";
         }
       }
     }
    }
    return "";
  }
}
