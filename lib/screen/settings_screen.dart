import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:ecommerce_store/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    
    return Scaffold(
      drawer: const OpenDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppbar(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                "settings".tr,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const Divider(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Theme Settings Section
                  _buildSectionHeader("theme_settings".tr, Icons.palette),
                  const SizedBox(height: 12),
                  
                  Obx(() => _buildSettingTile(
                    icon: settingsController.isDarkMode.value 
                        ? Icons.dark_mode 
                        : Icons.light_mode,
                    title: settingsController.isDarkMode.value 
                        ? "dark_mode".tr 
                        : "light_mode".tr,
                    subtitle: settingsController.isDarkMode.value 
                        ? "الوضع الليلي مُفعّل" 
                        : "الوضع النهاري مُفعّل",
                    trailing: Switch(
                      value: settingsController.isDarkMode.value,
                      onChanged: (value) => settingsController.toggleTheme(),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  )),

                  const SizedBox(height: 24),

                  // Language Settings Section
                  _buildSectionHeader("language_settings".tr, Icons.language),
                  const SizedBox(height: 12),
                  
                  Obx(() => _buildSettingTile(
                    icon: Icons.translate,
                    title: "language".tr,
                    subtitle: "${"current_language".tr}: ${settingsController.getLanguageName(settingsController.currentLanguage.value)}",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showLanguageDialog(context, settingsController),
                  )),

                  const SizedBox(height: 24),

                  // Account Settings Section
                  _buildSectionHeader("الحساب", Icons.account_circle),
                  const SizedBox(height: 12),
                  
                  _buildSettingTile(
                    icon: Icons.person,
                    title: "update_profile".tr,
                    subtitle: "تحديث المعلومات الشخصية",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Get.snackbar(
                        "قريباً",
                        "هذه الميزة ستكون متاحة قريباً",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    },
                  ),

                  _buildSettingTile(
                    icon: Icons.swap_horiz,
                    title: "change_account".tr,
                    subtitle: "التبديل إلى حساب آخر",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Get.snackbar(
                        "قريباً",
                        "هذه الميزة ستكون متاحة قريباً",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // App Info Section
                  _buildSectionHeader("معلومات التطبيق", Icons.info),
                  const SizedBox(height: 12),
                  
                  _buildSettingTile(
                    icon: Icons.help_outline,
                    title: "help".tr,
                    subtitle: "المساعدة والدعم",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Get.snackbar(
                        "المساعدة",
                        "للمساعدة، تواصل معنا عبر الإعدادات",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                  ),

                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "privacy".tr,
                    subtitle: "سياسة الخصوصية وشروط الاستخدام",
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Get.snackbar(
                        "الخصوصية",
                        "سياسة الخصوصية ستكون متاحة قريباً",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("select_language".tr),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.availableLanguages.length,
              itemBuilder: (context, index) {
                final language = controller.availableLanguages[index];
                final isSelected = language['code'] == controller.currentLanguage.value;
                
                return ListTile(
                  leading: Text(
                    language['flag'] ?? '🌐',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(language['name'] ?? ''),
                  trailing: isSelected 
                      ? const Icon(Icons.check, color: Colors.green) 
                      : null,
                  onTap: () {
                    controller.changeLanguage(language['code'] ?? 'ar');
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("cancel".tr),
            ),
          ],
        );
      },
    );
  }
}
