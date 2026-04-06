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

  var isLoading = false.obs; // 초기 로딩 상태 추가
  var isMoreLoading = false.obs;  // 리스트 바닥 추가 로딩 (새로 추가!)
  var hasMore = false.obs;
  final int _pageSize = 10;

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
    if (raw != null && raw.isNotEmpty) {
      List decoded = jsonDecode(raw);
      var fetched = decoded.map((e) => PocketMoney.fromJson(e)).toList();
      fetched.sort((a, b) => b.date.compareTo(a.date));
      allItems.assignAll(fetched);
    } else {
      allItems.clear();
    }
    _calculate();
    _refreshAfterUpdate();
  }

  void _calculate() {
    totalBalance.value = allItems.fold(0, (sum, item) => sum + item.amount);
  }

// 수정 전용 리프레시 함수 (현재 보고 있는 개수를 유지함)
  void _refreshAfterUpdate() {
    if (allItems.isEmpty) {
      displayItems.clear();
      hasMore.value = false;
      return;
    }

    // 핵심: 현재 화면에 보여주고 있는 개수(displayItems.length)만큼
    // 전체 리스트(allItems)에서 잘라옵니다.
    // 그래야 스크롤 위치에서 보던 데이터가 그대로 유지됩니다.
    int currentViewCount = displayItems.length;
    if (currentViewCount < _pageSize) currentViewCount = _pageSize;
    if (currentViewCount > allItems.length) currentViewCount = allItems.length;

    displayItems.assignAll(allItems.sublist(0, currentViewCount));
    hasMore.value = displayItems.length < allItems.length;
  }

// 스크롤 바닥 로딩 (전용 변수 사용)
  void _loadMore() async {
    if (isMoreLoading.value) return; // 중복 방지
    isMoreLoading.value = true;
    // 다음 데이터 가져오는 로직...
    int currentLen = displayItems.length;
    int nextEnd = currentLen + _pageSize;
    if (nextEnd > allItems.length) nextEnd = allItems.length;
    if (currentLen < nextEnd) {
      displayItems.addAll(allItems.sublist(currentLen, nextEnd));
      hasMore.value = displayItems.length < allItems.length;
    }
    isMoreLoading.value = false;
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
      if (id == null) {
        final newId = _generateRandomString(20);
        final newItem = PocketMoney(id: newId, title: title, amount: amount, date: DateTime.now());
        allItems.insert(0, newItem);

        // 새 데이터 추가 시에는 맨 위로 가니까 기존처럼 초기화
        _calculate();
        _refreshAfterUpdate();
      } else {
        int idx = allItems.indexWhere((e) => e.id == id);
        if (idx != -1) {
          allItems[idx] = PocketMoney(id: id, title: title, amount: amount, date: allItems[idx].date);
        }

        _calculate();
        // ★ 수정 시에는 개수를 유지하는 리프레시 호출!
        _refreshAfterUpdate();
      }

      final List<Map<String, dynamic>> jsonList = allItems.map((e) => e.toJson()).toList();
      final String encodedData = jsonEncode(jsonList);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('history', encodedData);

    } catch (e) {
      debugPrint("!!! 에러 발생: $e");
    }
  }

  String get formattedBalance {
    // 숫자를 문자열로 바꾸고, 뒤에서부터 3자리마다 콤마를 추가하는 정규식입니다.
    return totalBalance.value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
  }

  String formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
  }
}