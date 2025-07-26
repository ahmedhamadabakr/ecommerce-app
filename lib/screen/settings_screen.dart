import 'package:ecommerce_store/widget/button.dart';
import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: OpenDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            Divider(),

            Button(
              textBtn: "Update profile",
              color: Colors.blue,
              onTap: () {},
              icon: Icons.person,
            ),
            Button(
              textBtn: "change account",
              color: Colors.blue,
              onTap: () {},
              icon: Icons.account_circle,
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                disabledForegroundColor: Colors.red,
              ),
              onPressed: null,
              child: Text('TextButton'),
            ),
          ],
        ),
      ),
    );
  }
}
