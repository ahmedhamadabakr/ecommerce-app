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
import 'package:ecommerce_store/controllers/settings_controller.dart';
import 'package:ecommerce_store/translations/app_translations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  Get.put(CartController());
  Get.put(RegisterController());
  Get.put(ProductsController());
  Get.put(SettingsController());
  runApp(const Ecommerce());
}

class Ecommerce extends StatelessWidget {
  const Ecommerce({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    
    return Obx(() => GetMaterialApp(
      title: 'E-Commerce Store',
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => Home()),
        GetPage(name: "/login", page: () => LoginPage()),
        GetPage(name: kProductDetilRoute, page: () => ProductDetilScreen()),
        GetPage(name: kRegisterPage, page: () => RegisterPage()),
        GetPage(name: kRegisterPage2, page: () => RegisterStep2Page()),
        GetPage(name: kCartPage, page: () => Cart()),
        GetPage(name: kSettingspage, page: () => SettingsScreen()),
      ],
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      themeMode: settingsController.themeMode,
      
      // Internationalization
      locale: settingsController.currentLocale.value,
      fallbackLocale: const Locale('ar', 'SA'),
      translations: AppTranslations(),
      
      // RTL Support
      builder: (context, child) {
        return Directionality(
          textDirection: settingsController.currentLanguage.value == 'ar' 
              ? TextDirection.rtl 
              : TextDirection.ltr,
          child: child!,
        );
      },
    ));
  }
}


