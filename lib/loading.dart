

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';

class Loading {
  Loading.init() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..maskType = EasyLoadingMaskType.custom
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 60.0
      ..indicatorWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white38,
        ),
        height: 100,
        width: 100,
        child: Lottie.asset(
          'assets/lottie/loading.json',
        ),
      )
      ..radius = 100.0
    ..progressColor = Colors.blue
      ..backgroundColor = Colors.transparent
    ..indicatorColor = Colors.blue
      ..textColor = Colors.white
      ..maskColor = Colors.black45
      ..userInteractions = false
      ..dismissOnTap = false
      ..boxShadow = <BoxShadow>[]
      ..customAnimation = CustomAnimation();
  }
}


class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    double opacity = controller.value; //controller?.value ?? 0;
    return Opacity(
      opacity: opacity,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}
