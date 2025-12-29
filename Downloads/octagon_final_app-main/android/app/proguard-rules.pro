-keep class com.github.olubunmitosin.laravel_flutter_pusher.** { *; }

# Firebase core/messaging/firestore/storage rely on reflection when invoked from Flutter.
# Without explicit keep rules, R8 can strip the classes which only get touched once the
# user opens the group chat screen (first place we hit Firebase + Pusher) and the APK
# crashes immediately. Keeping the SDK surface ensures release builds stay stable.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Chat relies on OkHttp/Okio + the Java Pusher client. Make sure they survive shrinking.
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**
-keep class com.pusher.client.** { *; }
-dontwarn com.pusher.client.**
