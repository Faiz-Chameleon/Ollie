import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';


versionCheck(context) async {
  //Get Current installed version of app
  final PackageInfo info = await PackageInfo.fromPlatform();
  double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

  //Get Latest version info from firebase config
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  try {
    await remoteConfig.fetch();
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 0),
      minimumFetchInterval: const Duration(seconds: 1),
    ));

    await remoteConfig.fetchAndActivate();
    String latestVersion = remoteConfig.getString('force_update_version').trim().replaceAll('"', '');

    var data = jsonDecode(remoteConfig.getString("update_dialog"));

    double newVersion = double.parse(latestVersion.trim().replaceAll(".", ""));
    if (newVersion  > currentVersion) {
      _showVersionDialog(context, data["title"], data["message"]);
    }
  } on Exception catch (exception) {
    print(exception);
  } catch (exception) {
    print('Unable to fetch remote config. Cached or default values will be used');
  }
}

//Show Dialog to force user to update
_showVersionDialog(context, String remoteTitle, String remoteMessage) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String title = remoteTitle;
      String message = remoteMessage;
      String btnLabel = "Update now";
      return WillPopScope(
        onWillPop: (){
          return Future.value(false);
        },
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(btnLabel),
              onPressed: () => _launchUrl(),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _launchUrl() async {
  OpenStore.instance.open(
      appStoreId: '1673110067', // AppStore id of your app for iOS
      appStoreIdMacOS: '1673110067', // AppStore id of your app for MacOS (appStoreId used as default)
      androidAppBundleId: 'com.octagon.app', // Android app bundle package name
      // windowsProductId: '9NZTWSQNTD0S' // Microsoft store id for Widnows apps
  );
}
