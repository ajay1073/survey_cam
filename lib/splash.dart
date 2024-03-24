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
    CheckLoginLogic.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(image: AssetImage('images/splash.jpg')),
          SizedBox(
            height: screenSize.height * 0.1,
          ),
          const Text(
            "SurveyCam",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 40,
                fontWeight: FontWeight.w500),
          ),
          const Text(
            "(Version: 1.0.0)",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
