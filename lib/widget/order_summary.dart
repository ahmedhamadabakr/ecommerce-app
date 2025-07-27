import 'package:flutter/material.dart';
import 'package:ecommerce_store/controllers/cart_controller.dart';
import 'package:get/get.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    
    return Obx(() {
      final subtotal = cartController.totalPrice;
      final shipping = 0.0; // Free shipping
      final tax = subtotal * 0.1; // 10% tax
      final total = subtotal + shipping + tax;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildRow("Subtotal (${cartController.itemCount} items)", "\$${subtotal.toStringAsFixed(2)}"),
            _buildRow("Shipping", shipping > 0 ? "\$${shipping.toStringAsFixed(2)}" : "Free"),
            _buildRow("Tax", "\$${tax.toStringAsFixed(2)}"),

            const Divider(height: 24, thickness: 1),

            _buildRow("Total", "\$${total.toStringAsFixed(2)}", isBold: true),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: cartController.cartItems.isNotEmpty
                    ? () {
                        // TODO: Navigate to checkout
                        Get.snackbar(
                          'Checkout',
                          'Proceeding to checkout...',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                Get.back(); // يرجع للتسوق
              },
              child: const Text("Continue Shopping"),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
