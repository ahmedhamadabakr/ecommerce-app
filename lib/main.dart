import 'package:ecommerce_store/constent.dart';
import 'package:ecommerce_store/screen/cart.dart';
import 'package:ecommerce_store/screen/home.dart';
import 'package:ecommerce_store/screen/login_page.dart';
import 'package:ecommerce_store/screen/product_detil_screen.dart';
import 'package:ecommerce_store/screen/register_page.dart';
import 'package:ecommerce_store/screen/register_step2_page.dart';
import 'package:ecommerce_store/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_store/controllers/register_controller.dart';

void main() {
  // Initialize GetX controllers
  Get.put(RegisterController());
  runApp(const Ecommerce());
}

class Ecommerce extends StatelessWidget {
  const Ecommerce({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => Home()),
        GetPage(name: kProductDetilRoute, page: () => ProductDetilScreen()),
        GetPage(name: kRegisterPage, page: () => RegisterPage()),
        GetPage(name: kRegisterPage2, page: () => RegisterStep2Page()),
        GetPage(name: kLoginPage, page: () => LoginPage()),
        GetPage(name: kCartPage, page: () => Cart()),
        GetPage(name: kSettingspage, page: () => SettingsScreen()),
      ],
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
