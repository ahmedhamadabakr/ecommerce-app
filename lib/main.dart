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
import 'package:ecommerce_store/controllers/auth_controller.dart';
import 'package:ecommerce_store/controllers/cart_controller.dart';
import 'package:ecommerce_store/controllers/products_controller.dart';

void main() {
  print('Starting app...');
  // Initialize GetX controllers in correct order
  print('Initializing AuthController...');
  Get.put(AuthController()); // Initialize first
  print('Initializing CartController...');
  Get.put(CartController()); // Initialize after AuthController
  print('Initializing RegisterController...');
  Get.put(RegisterController());
  print('Initializing ProductsController...');
  Get.put(ProductsController());
  print('All controllers initialized, running app...');
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
    );
  }
}
