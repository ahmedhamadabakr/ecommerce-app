import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:ecommerce_store/widget/order_summary.dart';
import 'package:ecommerce_store/widget/product_item_incart.dart';
import 'package:flutter/material.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OpenDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppbar(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Cart Items (1)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: 10, // عدّل بناءً على عدد المنتجات الحقيقية
                itemBuilder: (context, index) {
                  return const ProductItemInCart();
                },
              ),
            ),
            OrderSummary(),

          ],
        ),
      ),
    );
  }
}
