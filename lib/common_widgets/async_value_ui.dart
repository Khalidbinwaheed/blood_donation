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
      final message = _errorMessage(error);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                icon: const Icon(
                  Icons.error_outline,
                  color: AppStyle.primaryColor,
                  size: 40,
                ),
                title: Text(
                  'Error',
                  style: AppStyle.headingTextStyle.copyWith(
                    color: AppStyle.primaryColor,
                    fontSize: 20,
                  ),
                ),
                content: Text(
                  message,
                  style:
                      AppStyle.normalTextStyle.copyWith(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyle.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  )
                ],
              ));
    }
  }
}

String _errorMessage(Object? error) {
  if (error is FirebaseAuthException) {
    return error.message ?? 'Authentication error occurred.';
  } else if (error != null) {
    return error.toString();
  } else {
    return 'An unknown error occurred.';
  }
}
