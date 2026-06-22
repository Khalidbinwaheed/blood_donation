import 'package:flutter/material.dart';

class SizeConfig {
  static double screenHeight = 0.0;
  static double screenWidth = 0.0;

  static void init(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }

  static double getProportionateHeight(double inputHeight) {
    double screenHeight = SizeConfig.screenHeight;
    return (inputHeight / 812.0) * screenHeight;
  }

  static double getProportionateWidth(double inputWidth) {
    double screenWidth = SizeConfig.screenWidth;
    return (inputWidth / 375.0) * screenWidth;
  }
}
