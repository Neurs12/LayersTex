import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';
import 'package:window_size/window_size.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'UIs/login.dart';
import 'UIs/home.dart';
import 'utils/google_sign_in_service.dart';

void main() async {
  try {
    if (Platform.isWindows) {
      setWindowTitle("LayersTex");
      GoogleSignInDart.register(
          clientId: "949984522577-6346tofcu0ml6gaegg6th0ii0aorghk3.apps.googleusercontent.com");
    }
  } catch (_) {}
  runApp(MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark, colorSchemeSeed: Colors.purple, useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WaitScreen()));
}

class WaitScreen extends StatelessWidget {
  const WaitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2)).then((value) {
        ggSignInSilent().then((userObj) {
          if (userObj.runtimeType != bool) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePageUI(userObj: userObj)));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const LoginUI()));
          }
        });
      });
    });
    return const Scaffold(body: LinearProgressIndicator());
  }
}
