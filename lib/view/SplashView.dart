import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // 애니메이션 제어 변수 (0.5초 뒤에 콘텐츠 등장)
    final RxBool isVisible = false.obs;

    // 0.5초 뒤에 콘텐츠(돈비, 중앙 로티, 텍스트)가 스르륵 나타나게 함
    Future.delayed(
      const Duration(milliseconds: 500),
      () => isVisible.value = true,
    );

    //3초 뒤 메인으로 이동 (애니메이션을 충분히 볼 수 있도록 0.5초 더 늘림)
    Future.delayed(
      const Duration(milliseconds: 3000),
      () => Get.offNamed('/home'),
    );

    return Scaffold(
      backgroundColor: Colors.black, // 사진이 로딩되기 전 잠깐 보일 배경색
      body: Stack(
        children: [
          // [층 1] 배경 이미지 (가장 아래)
          SizedBox.expand(
            child: Image.asset(
              'assets/images/son.jpg',
              fit: BoxFit.cover, // 화면에 꽉 차게
            ),
          ),

          // [층 2] 배경 이미지 위에 어두운 필터 (가독성 확보)
          Container(color: Colors.black.withOpacity(0.3)), // 조금 더 어둡게 조절
          // [층 3] 뒷 배경 전체에 내리는 돈비 애니메이션 (Obx로 투명도 제어)
          Obx(
            () => AnimatedOpacity(
              opacity: isVisible.value ? 0.6 : 0.0, // 너무 정신없지 않게 약간 투명하게(0.6)
              duration: const Duration(milliseconds: 2000),
              child: SizedBox.expand(
                child: Lottie.asset(
                  'assets/lottie/cashrain.json',
                  fit: BoxFit.cover, // 돈비가 화면 전체를 덮도록 설정
                ),
              ),
            ),
          ),
          // [층 4] 중앙 콘텐츠 (사진과 돈비 위에 올라감)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Obx로 중앙 콘텐츠의 투명도 제어
                Obx(
                  () => AnimatedOpacity(
                    opacity: isVisible.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1500),
                    // 조금 더 천천히 등장
                    curve: Curves.easeOutCubic,
                    // 부드러운 시작
                    child: Column(
                      children: [
                        // 로티 애니메이션 (중앙 표기)
                        Lottie.asset(
                          'assets/lottie/money.json',
                          width: 280, // 크기를 살짝 더 키움
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 30), // 여백을 조금 더 줌
                        // 앱 타이틀
                        const Text(
                          "똑똑한 용돈 대장",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            // 42는 너무 커서 폰마다 잘릴 수 있어 40으로 살짝 조절
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 15,
                                offset: Offset(3, 3),
                              ),
                            ], // 글자가 더 잘 보이도록 그림자 강화
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
