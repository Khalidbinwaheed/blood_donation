import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
  const CommonButton({
    super.key,
    required this.onTap,
    required this.title,
    required this.isLoading,
  });
  final VoidCallback onTap;
  final String title;
  final bool isLoading;

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        alignment: Alignment.center,
        height: SizeConfig.getProportionateHeight(50),
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          color: AppStyle.mainColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child:
            widget.isLoading
                ? CircularProgressIndicator()
                : Text(widget.title, style: AppStyle.normalTextStyle),
      ),
    );
  }
}
