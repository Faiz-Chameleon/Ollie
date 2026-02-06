import 'dart:developer';
import 'dart:io';

// import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:octagon/binding/globalBinding.dart';
import 'package:octagon/firebase_options.dart';
import 'package:octagon/screen/group/pusher_implementation/pusher_service.dart';

import 'package:octagon/screen/splash_screen.dart';

import 'package:octagon/screen/tabs_screen.dart';

import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:resize/resize.dart';
import 'package:sizer/sizer.dart';

GetStorage storage = GetStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initFirebaseNotifications();
  // ✅ Use platform-specific options if auto config isn't set up
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await Firebase.initializeApp();
  await GetStorage.init();
  storage = GetStorage();
  Get.put<PusherService>(PusherService(), permanent: true);
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  messaging.onTokenRefresh.listen((token) {
    if (token.isNotEmpty) {
      storage.write("fcmToken", token);
    }
  });
  String? fcmToken;
  if (Platform.isIOS || Platform.isMacOS) {
    final apnsToken = await messaging.getAPNSToken();
    if (apnsToken == null) {
      log('APNS token not set yet; will wait for onTokenRefresh.');
    } else {
      fcmToken = await messaging.getToken();
    }
  } else {
    try {
      fcmToken = await messaging.getToken();
    } catch (e) {
      log('Failed to fetch FCM token: $e');
    }
  }
  log("FCM---- $fcmToken");
  if (fcmToken != null && fcmToken.isNotEmpty) {
    storage.write("fcmToken", fcmToken);
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor, // status bar color
      statusBarIconBrightness: statusBarBrightness,
      statusBarBrightness: Brightness.dark // status bar icon color
      ));
  runApp(
      ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier(), child: Consumer<ThemeNotifier>(builder: (_, model, __) => MyApp(model))));
}

class MyApp extends StatefulWidget {
  final ThemeNotifier model;

  const MyApp(this.model, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (storage.read("current_uid") != null && "${storage.read("current_uid")}".isNotEmpty) {
        setState(() {
          isLogin = true;
        });
        // await _initializePusher();
      }
    });
  }

  // Future<void> _initializePusher() async {
  //   try {
  //     // Wait a bit for the app to fully initialize
  //     await Future.delayed(Duration(seconds: 2));

  //     final token = storage.read("token");
  //     if (token != null && token.isNotEmpty) {
  //       final pusherService = Get.find<PusherService>();
  //       await pusherService.initializePusher();
  //       log("Pusher initialized successfully");

  //       // You can also subscribe to global channels here if needed
  //       final userId = storage.read("current_uid");
  //       if (userId != null) {
  //         // await pusherService.subscribeToUserNotifications(userId.toString());
  //       }
  //     } else {
  //       log("No auth token found for Pusher");
  //     }
  //   } catch (e) {
  //     log("Pusher initialization error: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, _, deviceType) {
      return Resize(builder: () {
        return GetMaterialApp(
          initialBinding: Globalbinding(),
          debugShowCheckedModeBanner: false,
          // navigatorKey: _navigatorKey,
          title: 'Octagon',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: isLogin ? TabScreen() : const SplashScreen(),
        );
      });
    });
  }
}
