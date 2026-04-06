import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:my_son_pocket/controller/PocketMoneyController.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(PocketMoneyController());
  DateTime? lastPressed;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        // 마지막으로 누른 지 2초가 지났거나 처음 누른 경우
        if (lastPressed == null || now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          // 아이가 보기 쉬운 하단 메시지(스낵바) 표시
          Get.snackbar(
            "잠깐!",
            "한 번 더 누르면 앱이 꺼져요 🏠",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(15),
          );
        } else {
          // 2초 이내에 다시 누른 경우 안드로이드 앱 완전히 종료
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false, // 왼쪽 정렬을 위해 false 설정
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 배치
            children: [
              const Text(
                "용돈 기록",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              // 오른쪽에 들어갈 귀여운 로티 애니메이션
              Lottie.asset(
                'assets/lottie/robot.json', // 준비하신 로티 파일 경로
                width: 45,
                height: 45,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Obx(
              () => Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    // 보라~파랑 그래디언트
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "지금 사용할 수 있는 돈",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${controller.totalBalance}원",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text(
                    "얼만큼 쓰고 받았을까?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // 아래 영역: 인피니티 스크롤 내역
            Expanded(
              child: Obx(() {
                // 1. 초기 로딩 중일 때
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. 데이터가 하나도 없을 때
                if (controller.displayItems.isEmpty) {
                  return const Center(
                    child: Text(
                      "아직 기록이 없어요.\n+ 버튼을 눌러 추가해보세요!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                // 3. 데이터가 있을 때 리스트 표시
                // 3. 데이터가 있을 때 리스트 표시 (이쁘게 꾸민 버전)
                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount:
                      controller.displayItems.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // 인피니티 스크롤 로딩 인디케이터
                    if (index == controller.displayItems.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final item = controller.displayItems[index];
                    final bool isIncome = item.amount >= 0; // 플러스 금액인지 확인
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), // 카드 사이 간격
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4), // 아래쪽으로 부드러운 그림자
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isIncome
                                ? Colors.blue.shade50
                                : Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncome
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline,
                            color: isIncome ? Colors.blue : Colors.orange,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0xFF333333),
                          ),
                        ),
                        subtitle: Text(
                          item.date.toString().split(' ')[0],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Text(
                          "${isIncome ? '+' : ''}${item.amount}원",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: isIncome
                                ? Colors.blueAccent
                                : Colors.redAccent,
                          ),
                        ),
                        onTap: () => Get.toNamed('/edit', arguments: item),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/add'),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
