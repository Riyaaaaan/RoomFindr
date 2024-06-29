import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_finder/widgets/bottom_nav.dart';
import 'login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressed;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final now = DateTime.now();
        final difference = lastPressed == null
            ? const Duration(seconds: 3)
            : now.difference(lastPressed!);

        if (difference > const Duration(seconds: 2)) {
          lastPressed = now;

          const message = 'Press back again to exit';

          Fluttertoast.showToast(msg: message, fontSize: 18);

          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Press back again to exit'),
          //     duration: Duration(seconds: 2),
          //   ),
          // );
        } else {
          // Exit the app
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        }
      },
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const BottomNav();
            } else {
              return const LoginOrRegister();
            }
          },
        ),
      ),
    );
  }
}
