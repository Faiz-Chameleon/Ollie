import 'package:get/get.dart';

import 'package:octagon/screen/mainFeed/home/home_controller.dart';
import 'package:octagon/screen/mainFeed/home/new_homecontroller.dart';

class Globalbinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>((HomeController()), permanent: true);
    Get.put<NewHomecontroller>((NewHomecontroller()), permanent: true);
    // Register PusherService so it can be retrieved with Get.find<PusherService>()
    // Get.put<PusherService>(PusherService(), permanent: true);
    // Get.lazyPut<PusherService>(() => PusherService(), fenix: true);
    // Get.put<ProfileController>((ProfileController()), permanent: true);
    // Get.put((ProfileController()), permanent: true);
  }
}
