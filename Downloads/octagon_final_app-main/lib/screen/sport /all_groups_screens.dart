import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/setting/group_controller.dart';
import 'package:octagon/screen/tabs_screen.dart';

import '../../utils/theme/theme_constants.dart';
import 'group_controller.dart';

class AllGroupsScreen extends StatefulWidget {
  bool isUpdate = false;
  AllGroupsScreen({super.key, this.isUpdate = false});

  @override
  State<AllGroupsScreen> createState() => _AllGroupsScreenState();
}

class _AllGroupsScreenState extends State<AllGroupsScreen> {
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
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabScreen()));
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
        body: Obx(() {
          return groupController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: groupController.groupData.length,
                  itemBuilder: (context, index) {
                    return Text(groupController.groupData[index]['name']);
                  },
                );
        }),
      )),
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
