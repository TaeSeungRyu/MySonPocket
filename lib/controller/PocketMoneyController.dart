import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_son_pocket/vo/PocketMoney.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PocketMoneyController extends GetxController {
  // 스크롤 컨트롤러
  final ScrollController scrollController = ScrollController();

  var items = <PocketMoney>[].obs; // 전체 내역
  var displayItems = <PocketMoney>[].obs; // 화면에 보여줄 내역 (페이징)
  var totalBalance = 0.obs;

  int _pageSize = 10;
  var hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData(); // 데이터 로드

    // 스크롤 리스너 등록
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (hasMore.value) {
          _loadMore();
        }
      }
    });
  }

  // 데이터 로드 (SharedPrefs)
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? rawData = prefs.getString('history');
    if (rawData != null) {
      List decoded = jsonDecode(rawData);
      items.value = decoded.map((e) => PocketMoney.fromJson(e)).toList();
      _calculateBalance();
      _refreshDisplay();
    }
  }

  // 데이터 추가/수정 후 저장
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString('history', encoded);
    _calculateBalance();
    _refreshDisplay();
  }

  void _calculateBalance() {
    totalBalance.value = items.fold(0, (sum, item) => sum + item.amount);
  }

  // 인피니티 스크롤용 페이징 로직
  void _refreshDisplay() {
    int end = items.length < _pageSize ? items.length : _pageSize;
    displayItems.value = items.sublist(0, end);
    hasMore.value = displayItems.length < items.length;
  }

  void _loadMore() {
    int nextEnd = displayItems.length + _pageSize;
    if (nextEnd > items.length) nextEnd = items.length;

    // 로딩 효과를 위해 약간의 지연 (선택)
    Future.delayed(Duration(milliseconds: 500), () {
      displayItems.addAll(items.sublist(displayItems.length, nextEnd));
      hasMore.value = displayItems.length < items.length;
    });
  }

  // 아이템 추가 및 수정 함수
  void addOrUpdate(PocketMoney item, {bool isEdit = false}) {
    if (isEdit) {
      int idx = items.indexWhere((e) => e.id == item.id);
      items[idx] = item;
    } else {
      items.insert(0, item); // 최신순으로 맨 앞에 추가
    }
    saveData();
  }
}