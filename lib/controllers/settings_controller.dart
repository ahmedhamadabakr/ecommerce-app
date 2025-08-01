import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Theme
  var isDarkMode = false.obs;

  // Language
  var currentLanguage = 'ar'.obs;
  var currentLocale = const Locale('ar', 'SA').obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Load saved settings
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme
      isDarkMode.value = prefs.getBool('isDarkMode') ?? false;

      // Load language
      currentLanguage.value = prefs.getString('language') ?? 'ar';
      _updateLocale(currentLanguage.value);

      // Update GetX theme
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Toggle dark/light mode
  Future<void> toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode.value);

      // Update GetX theme
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

      // Show confirmation
      Get.snackbar(
        isDarkMode.value ? 'الوضع الليلي' : 'الوضع النهاري',
        isDarkMode.value ? 'تم تفعيل الوضع الليلي' : 'تم تفعيل الوضع النهاري',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isDarkMode.value ? Colors.grey[800] : Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    try {
      currentLanguage.value = languageCode;
      _updateLocale(languageCode);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);

      // Update GetX locale
      Get.updateLocale(currentLocale.value);

      // Show confirmation
      Get.snackbar(
        languageCode == 'ar' ? 'تم تغيير اللغة' : 'Language Changed',
        languageCode == 'ar'
            ? 'تم تغيير اللغة إلى العربية'
            : 'Language changed to English',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  void _updateLocale(String languageCode) {
    switch (languageCode) {
      case 'ar':
        currentLocale.value = const Locale('ar', 'SA');
        break;
      case 'en':
        currentLocale.value = const Locale('en', 'US');
        break;
      default:
        currentLocale.value = const Locale('ar', 'SA');
    }
  }

  // Get current theme mode for MaterialApp
  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // Get available languages
  List<Map<String, String>> get availableLanguages => [
    {'code': 'ar', 'name': 'العربية', 'flag': 'EG'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  ];

  String getLanguageName(String code) {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'العربية'},
    );
    return language['name'] ?? 'العربية';
  }
}
