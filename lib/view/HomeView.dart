import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_son_pocket/controller/PocketMoneyController.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(PocketMoneyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("용돈기입장")),
      body: Column(
        children: [
          // 상단 영역: 현재 남은 금액
          Obx(() => Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)], // 보라~파랑 그래디언트
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("지금 사용할 수 있는 돈", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                Text("${controller.totalBalance}원",
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            ),
          ),),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.indigo),
                SizedBox(width: 8),
                Text("얼만큼 쓰고 받았을까?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  child: Text("아직 기록이 없어요.\n+ 버튼을 눌러 추가해보세요!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                );
              }
              // 3. 데이터가 있을 때 리스트 표시
// 3. 데이터가 있을 때 리스트 표시 (이쁘게 꾸민 버전)
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: controller.displayItems.length + (controller.hasMore.value ? 1 : 0),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isIncome ? Colors.blue.shade50 : Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
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
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      trailing: Text(
                        "${isIncome ? '+' : ''}${item.amount}원",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.blueAccent : Colors.redAccent,
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
    );
  }
}