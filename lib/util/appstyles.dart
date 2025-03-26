import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static final headingTextStyle = GoogleFonts.lobsterTwo(
    fontSize: SizeConfig.getProportionateHeight(20),
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  static final titleTextStyle = GoogleFonts.lobsterTwo(
    fontSize: SizeConfig.getProportionateHeight(18),
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );
  static final normalTextStyle = GoogleFonts.lobsterTwo(
    fontSize: SizeConfig.getProportionateHeight(15),
    color: Colors.white,
    fontWeight: FontWeight.w400,
  );

  static const mainColor = Color(0xff680c07);
}
