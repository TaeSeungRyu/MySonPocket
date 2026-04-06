import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_son_pocket/vo/PocketMoney.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PocketMoneyController extends GetxController {
  final ScrollController scrollController = ScrollController();
  var allItems = <PocketMoney>[].obs;
  var displayItems = <PocketMoney>[].obs;
  var totalBalance = 0.obs;

  var isLoading = true.obs; // 초기 로딩 상태 추가
  var hasMore = false.obs;
  final int _pageSize = 15;

  @override
  void onInit() {
    super.onInit();
    initApp();

    scrollController.addListener(() {
      // 바닥에 닿았을 때 추가 로드
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
        if (hasMore.value && !isLoading.value) {
          _loadMore();
        }
      }
    });
  }

  Future<void> initApp() async {
    isLoading.value = true;
    await loadData();
    isLoading.value = false;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString('history');

    debugPrint("로드된 데이터: $raw");

    if (raw != null && raw.isNotEmpty) {
      List decoded = jsonDecode(raw);
      var fetched = decoded.map((e) => PocketMoney.fromJson(e)).toList();
      fetched.sort((a, b) => b.date.compareTo(a.date));
      allItems.assignAll(fetched);
    } else {
      allItems.clear();
    }

    _calculate();
    _refreshDisplay();
  }

  void _calculate() {
    totalBalance.value = allItems.fold(0, (sum, item) => sum + item.amount);
  }

  void _refreshDisplay() {
    if (allItems.isEmpty) {
      displayItems.clear();
      hasMore.value = false;
      return;
    }
    int end = allItems.length < _pageSize ? allItems.length : _pageSize;
    displayItems.assignAll(allItems.sublist(0, end));
    hasMore.value = displayItems.length < allItems.length;
  }

  void _loadMore() {
    int currentLen = displayItems.length;
    int nextEnd = currentLen + _pageSize;
    if (nextEnd > allItems.length) nextEnd = allItems.length;
    if (currentLen < nextEnd) {
      // 실제 데이터를 더 가져오는 동안 중복 호출 방지
      displayItems.addAll(allItems.sublist(currentLen, nextEnd));
      hasMore.value = displayItems.length < allItems.length;
    }
  }

  String _generateRandomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))
    ));
  }


  // 저장 로직 (데이터 추가 후 리스트 즉시 갱신)
  Future<void> addOrUpdate(String? id, String title, int amount) async {
    try {
      debugPrint("--- addOrUpdate 시작 ---");

      if (id == null) {
        final newId = _generateRandomString(20);
        final newItem = PocketMoney(id: newId, title: title, amount: amount, date: DateTime.now());
        allItems.insert(0, newItem);
        debugPrint("새 아이템 추가됨: $newId");
      } else {
        int idx = allItems.indexWhere((e) => e.id == id);
        if (idx != -1) {
          allItems[idx] = PocketMoney(id: id, title: title, amount: amount, date: allItems[idx].date);
          debugPrint("기존 아이템 수정됨: $id");
        }
      }

      // JSON 변환 시도 (이 구간에서 에러가 많이 납니다)
      final List<Map<String, dynamic>> jsonList = allItems.map((e) => e.toJson()).toList();
      final String encodedData = jsonEncode(jsonList);

      debugPrint("데이터 변환 성공: $encodedData");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('history', encodedData);

      _calculate();
      _refreshDisplay();

      debugPrint("--- 저장 프로세스 완료 ---");

    } catch (e, stacktrace) {
      // 에러가 나면 콘솔에 빨간색으로 원인을 찍어줍니다.
      debugPrint("!!! 에러 발생: $e");
      debugPrint("스택트레이스: $stacktrace");
    }
  }
}