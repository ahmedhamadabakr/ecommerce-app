import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  RxString selectedItem = ''.obs;
}

class CustomMenuScreen extends StatelessWidget {
  CustomMenuScreen({super.key});

  final MenuController controller = Get.put(MenuController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Side Menu Navigation'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Menu Options',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.looks_one),
              title: const Text('Option One'),
              onTap: () {
                controller.selectedItem.value = 'Option One';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.looks_two),
              title: const Text('Option Two'),
              onTap: () {
                controller.selectedItem.value = 'Option Two';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.looks_3),
              title: const Text('Option Three'),
              onTap: () {
                controller.selectedItem.value = 'Option Three';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Obx(() => controller.selectedItem.value.isEmpty
            ? const Text('Tap the menu icon to select an option')
            : Text('Selected: ${controller.selectedItem.value}')),
      ),
    );
  }
}
