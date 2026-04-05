import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_son_pocket/view/HomeView.dart';
import 'package:my_son_pocket/view/PocketMoneyFormView.dart';
import 'package:my_son_pocket/view/SplashView.dart';

void main() {
  runApp(
    GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashView()),
        GetPage(name: '/home', page: () => HomeView()),
        GetPage(name: '/add', page: () => PocketMoneyFormView()),
        GetPage(name: '/edit', page: () => PocketMoneyFormView()),
      ],
    ),
  );
}
