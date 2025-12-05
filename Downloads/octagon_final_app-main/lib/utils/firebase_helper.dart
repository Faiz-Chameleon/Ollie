// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:octagon/utils/notification_utils.dart';
import '../firebase_options.dart';
import '../main.dart';

initFirebaseNotifications() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // messaging.getToken().then((value) {
  //   print(value);
  // });
  messaging.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  messaging.getToken().then((token) {
    print(token);
    storage.write("fcm_token", token);
  });

  messaging.subscribeToTopic("all");

  // AwesomeNotifications().requestPermissionToSendNotifications();

  // NotificationController.initializeLocalNotifications();

  listenFirebaseNotification();
}

listenFirebaseNotification() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      // NotificationController.createNewNotification(title: message.notification?.title??"", body: message.notification?.body??"", imageUrl: android.imageUrl??"");
    }
  });
}
