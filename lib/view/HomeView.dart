import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
            padding: EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Text("현재 남은 용돈"),
                Text("${controller.totalBalance}원",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          )),
          // 아래 영역: 인피니티 스크롤 내역
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController, // 중요!
              itemCount: controller.displayItems.length + (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.displayItems.length) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final item = controller.displayItems[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text("${item.amount}원"),
                  onTap: () => Get.toNamed('/edit', arguments: item), // 수정 화면으로 이동
                );
              },
            )),
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