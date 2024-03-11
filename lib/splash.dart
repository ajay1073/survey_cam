import 'package:flutter/material.dart';
import 'package:survey_cam/authentication/utils/check_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CheckLoginLogic.checkLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Welcome to SurveyCam",
          style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 59,
              fontWeight: FontWeight.w500),
        ), // or any other loading indicator
      ),
    );
  }
}
