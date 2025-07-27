import 'package:ecommerce_store/constent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_store/controllers/auth_controller.dart';

class OpenDrawer extends StatelessWidget {
  const OpenDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 250, // تكبير المساحة
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue,
                  Colors.blue.shade700,
                  Colors.blue.shade900,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/15.png'),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15), // مساحة أكبر بين الصورة والنص
                // User Name
                Obx(() => Text(
                  authController.isAuthenticated.value ? "مرحباً بك" : "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // تكبير الخط
                    fontWeight: FontWeight.bold,
                  ),
                )),
                SizedBox(height: 5),
                Obx(() => Text(
                  authController.isAuthenticated.value 
                      ? (authController.currentUser?.fullName.isNotEmpty == true 
                          ? authController.currentUser!.fullName 
                          : authController.currentUser?.email ?? "User")
                      : "Guest",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18, // تكبير الخط
                    fontWeight: FontWeight.w500,
                  ),
                )),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(() => Text(
                    authController.isAuthenticated.value ? "Active Member" : "Guest User",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
                SizedBox(height: 8),
                // Show user email if authenticated
                Obx(() => authController.isAuthenticated.value && authController.currentUser?.email.isNotEmpty == true
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authController.currentUser!.email,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SizedBox()),
                // Show user phone if authenticated
                Obx(() => authController.isAuthenticated.value && authController.currentUser?.phone.isNotEmpty == true
                    ? Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "📞 ${authController.currentUser!.phone}",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SizedBox()),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home page'),
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed('/');
            },
          ),
          Obx(() => authController.isAuthenticated.value
              ? ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    // TODO: Navigate to profile page
                    Get.snackbar(
                      'Profile',
                      'Profile page coming soon...',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                )
              : ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login'),
                  onTap: () {
                    Get.toNamed(kLoginPage);
                  },
                )),
          Obx(() => authController.isAuthenticated.value
              ? const SizedBox()
              : ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Register'),
                  onTap: () {
                    Get.toNamed(kRegisterPage);
                  },
                )),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Cart'),
            onTap: () {
              if (authController.isAuthenticated.value) {
                Get.toNamed(kCartPage);
              } else {
                Get.snackbar(
                  'Authentication Required',
                  'Please login to view your cart',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                Get.toNamed(kLoginPage);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('setings'),
            onTap: () {
              Get.toNamed(kSettingspage);
            },
          ),
          Obx(() => authController.isAuthenticated.value
              ? ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {
                    Navigator.of(context).pop();
                    authController.logout();
                  },
                )
              : const SizedBox()),
        ],
      ),
    );
  }
}
