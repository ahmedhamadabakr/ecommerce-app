import 'package:ecommerce_store/constent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpenDrawer extends StatelessWidget {
  const OpenDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text(
                  "wellcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // تكبير الخط
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Ahmed",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18, // تكبير الخط
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Active Member",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Login'),
            onTap: () {
              Get.toNamed(kLoginPage);
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Register'),
            onTap: () {
              Get.toNamed(kRegisterPage);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Cart'),
            onTap: () {
              Get.toNamed(kCartPage);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('setings'),
            onTap: () {
              Get.toNamed(kSettingspage);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed('/logout');
            },
          ),
        ],
      ),
    );
  }
}
