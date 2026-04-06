import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart'; // Lottie 임포트

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // 3초 뒤 메인으로 이동
    Future.delayed(Duration(seconds: 3), () => Get.offNamed('/home'));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/money.json',
              width: 250,
              height: 250,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 20),
            Text(
              "똑똑한 용돈 대장",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
