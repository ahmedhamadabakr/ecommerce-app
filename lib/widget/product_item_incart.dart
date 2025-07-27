import 'package:flutter/material.dart';
import 'package:ecommerce_store/controllers/cart_controller.dart';
import 'package:get/get.dart';

class ProductItemInCart extends StatelessWidget {
  final CartItem cartItem;
  
  const ProductItemInCart({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cartItem.image.isNotEmpty
                ? Image.network(
                    cartItem.image,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/15.png",
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    "assets/15.png",
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 12),

          // تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Price: \$${cartItem.price.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 8),

                // تحكم الكمية + حذف
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (cartItem.quantity > 1) {
                              cartController.updateQuantity(cartItem.id, cartItem.quantity - 1);
                            } else {
                              cartController.removeFromCart(cartItem.id);
                            }
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            cartItem.quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            cartController.updateQuantity(cartItem.id, cartItem.quantity + 1);
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "\$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            cartController.removeFromCart(cartItem.id);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
