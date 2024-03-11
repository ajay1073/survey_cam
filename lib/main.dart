// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:survey_cam/authentication/login.dart';
import 'package:survey_cam/camerapage.dart';
import 'package:survey_cam/splash.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        // home: CaptureAndStampImage(
        //   role: "User",
        // ));
        // home: SignUpPage());
        home: SplashScreen());
    // home: CodeGeneratorScreen());
    // yeh vala
    // home: CameraApp()
    // home: CameraScreen(),
  }
}
