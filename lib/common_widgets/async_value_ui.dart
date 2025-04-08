import 'package:blood_donation/util/appstyles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueUi on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    if (!isLoading && hasError) {
      if (ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
    }
    final massage = _errorMessage(error);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.error,
                color: Color(0xFF680c07),
                size: 40,
              ),
              title: Text(
                massage,
                style: AppStyle.normalTextStyle
                    .copyWith(color: const Color(0xFF680c07)),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF680c07)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: AppStyle.normalTextStyle,
                      ),
                    )
                  ],
                )
              ],
            ));
  }
}

String _errorMessage(Object? error) {
  if (error is FirebaseAuthException) {
    return error.message ?? error.toString();
  } else {
    return error.toString();
  }
}
