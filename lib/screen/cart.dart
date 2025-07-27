import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:ecommerce_store/widget/order_summary.dart';
import 'package:ecommerce_store/widget/product_item_incart.dart';
import 'package:ecommerce_store/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());
    
    return Scaffold(
      drawer: const OpenDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppbar(),
            Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Cart Items (${cartController.itemCount})",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),

            const Divider(),

            Expanded(
              child: Obx(() {
                if (cartController.loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (cartController.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${cartController.error.value}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () => cartController.refreshCart(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (cartController.cartItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some products to your cart',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => cartController.refreshCart(),
                  child: ListView.builder(
                    itemCount: cartController.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartController.cartItems[index];
                      return ProductItemInCart(cartItem: cartItem);
                    },
                  ),
                );
              }),
            ),
            Obx(() => cartController.cartItems.isNotEmpty ? OrderSummary() : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
