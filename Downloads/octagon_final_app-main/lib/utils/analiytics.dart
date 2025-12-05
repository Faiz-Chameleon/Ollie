

import 'package:firebase_analytics/firebase_analytics.dart';

import '../main.dart';

publishAmplitudeEvent({Map<String, dynamic>? logEvent, String eventType = ""}){
  // FirebaseAnalytics.instance.logEvent(
  //   name: eventType,
  //   parameters: logEvent
  // );
}

setAmplitudeUserProperties(){
  FirebaseAnalytics.instance.setUserProperty(name: storage.read("user_name"), value: storage.read("email"));
  FirebaseAnalytics.instance.setUserId(id: "${storage.read("current_uid")}");
}

// addSessionCount(){
//   Identify identify = Identify();
//   identify.add(StringK.kNumOfTotalSession, 1);
//   Amplitude.getInstance().identify(identify);
// }