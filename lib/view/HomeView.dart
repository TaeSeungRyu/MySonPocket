import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:my_son_pocket/component/BalanceCard.dart';
import 'package:my_son_pocket/component/TransactionTile.dart';
import 'package:my_son_pocket/controller/PocketMoneyController.dart';


class HomeView extends StatelessWidget {
  final controller = Get.put(PocketMoneyController());
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopAction, // 로직을 아래 별도 메서드로 뺐습니다.
      child: Stack(
        children: [
          _buildBackground(), // 배경 레이어 분리
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(), // 앱바 분리
            body: Column(
              children: [
                Obx(() => BalanceCard(formattedBalance: controller.formattedBalance)),
                _buildListHeader(), // "얼만큼 쓰고..." 헤더 분리
                Expanded(child: _buildTransactionList()), // 리스트 영역 분리
              ],
            ),
            floatingActionButton: _buildFab(), // FAB 분리
          ),
        ],
      ),
    );
  }

  // --- UI 구성 요소 (Private Methods) ---

  Widget _buildBackground() {
    return Stack(
      children: [
        SizedBox.expand(child: Image.asset('assets/images/background.png', fit: BoxFit.cover)),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.4)],
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.7),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
              "너의 용돈!",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
          ),
          // 로티 위치를 위아래로 미세하게 조정
          Transform.translate(
            offset: const Offset(0, -10), // 첫 번째 숫자는 가로(X), 두 번째 숫자는 세로(Y)입니다. 마이너스면 위로 올라가요!
            child: Lottie.asset(
              'assets/lottie/robot.json',
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.list_alt, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text("얼만큼 쓰고 얼마를 받았을까?!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (controller.isLoading.value && controller.displayItems.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.displayItems.isEmpty) {
        return const Center(child: Text("아직 기록이 없어요."));
      }

      // 데이터가 있을 때
      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        // [수정] 데이터가 더 없더라도 "마지막 문구"를 보여주기 위해 무조건 + 1을 해줍니다.
        itemCount: controller.displayItems.length + 1,
        itemBuilder: (context, index) {

          // 리스트의 맨 마지막 아이템 다음에 올 위젯 처리
          if (index == controller.displayItems.length) {
            return Obx(() {
              if (controller.hasMore.value) {
                // 1. 데이터를 더 가져오는 중일 때 (로딩 바)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              } else if(index >= 5){
                // 2. [추가] 모든 데이터를 다 보여줬을 때 (마지막 안내)
                return _buildEndOfList();
              } else {
                return const SizedBox(height: 80); // FAB에 가려지지 않도록 충분한 여백
              }
            });
          }

          final item = controller.displayItems[index];
          return TransactionTile(
            item: item,
            formattedAmount: controller.formatNumber(item.amount),
            onTap: () => Get.toNamed('/edit', arguments: item),
          );
        },
      );
    });
  }

  Widget _buildEndOfList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.grey.shade700, size: 30),
          const SizedBox(height: 8),
          Text(
            "모든 기록을 다 읽었어!\n너는 정말 알뜰살뜰 멋쟁이 칭찬해 👍",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 50), // FAB에 가려지지 않게 여유 공간
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/add'),
      icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
      label: const Text("용돈 적기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: const Color(0xFF764ba2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // --- 로직 (Logic) ---

  void _handlePopAction(bool didPop, dynamic result) {
    if (didPop) return;
    final now = DateTime.now();
    if (lastPressed == null || now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      Get.snackbar("잠깐!", "한 번 더 누르면 앱이 꺼져요 🏠",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.black87, colorText: Colors.white);
    } else {
      SystemNavigator.pop();
    }
  }
}
