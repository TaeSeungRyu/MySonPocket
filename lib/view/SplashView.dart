import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // 애니메이션 제어 변수
    final RxBool isVisible = false.obs;

    // 0.5초 뒤에 콘텐츠(로티, 텍스트)가 나타나게 함
    Future.delayed(const Duration(milliseconds: 500), () => isVisible.value = true);
    // 3.5초 뒤 메인으로 이동
    Future.delayed(const Duration(milliseconds: 3500), () => Get.offNamed('/home'));
    return Scaffold(
      body: Stack(
        children: [
          // 1. 배경 이미지 (가장 아래에 깔림)
          SizedBox.expand( // 화면 전체를 채우도록 설정
            child: Image.asset(
              'assets/images/son.jpg',
              fit: BoxFit.cover, // 이미지가 비율에 맞게 화면을 꽉 채움
            ),
          ),
          // 2. 배경 이미지를 살짝 어둡게 하거나 필터를 주고 싶을 때 (선택 사항)
          // 사진 위에 글자가 잘 안 보인다면 아래 검정색 투명 레이어를 사용하세요.
          Container(color: Colors.black.withOpacity(0.2)),
          // 3. 중앙 콘텐츠 (사진 위에 올라감)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => AnimatedOpacity(
                  opacity: isVisible.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeIn,
                  child: Column(
                    children: [
                      // 로티 애니메이션
                      Lottie.asset(
                        'assets/lottie/money.json',
                        width: 250,
                        height: 250,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 20),
                      // 앱 타이틀
                      const Text(
                        "똑똑한 용돈 대장",
                        style: TextStyle(
                          color: Colors.white, // 배경이 사진이므로 흰색 글씨 추천
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(2, 2))
                          ], // 글자가 잘 보이도록 그림자 추가
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}