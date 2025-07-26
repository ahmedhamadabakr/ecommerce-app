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
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.blue.shade700],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    'assets/15.png',
                  ), // Using existing image from assets
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
                // User Name
                Text(
                  "wellcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Ahmed",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
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
