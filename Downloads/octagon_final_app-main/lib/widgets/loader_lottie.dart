import 'package:lottie/lottie.dart';

loaderLottie(){
 return Lottie.asset(
    'assets/Animation.json',
    onLoaded: (composition) {
      // Configure the AnimationController with the duration of the
      // Lottie file and start the animation.
      // _controller
      //   ..duration = composition.duration
      //   ..forward();
    },
  );
}