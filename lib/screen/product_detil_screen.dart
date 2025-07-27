import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:ecommerce_store/controllers/products_controller.dart';
import 'package:ecommerce_store/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetilScreen extends StatelessWidget {
  const ProductDetilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = Get.arguments as Product;
    final CartController cartController = Get.find<CartController>();
    
    return Scaffold(
      drawer: OpenDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomAppbar(),

              // صورة المنتج
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.image.isNotEmpty
                    ? Image.network(
                        product.image,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/15.png",
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        "assets/15.png",
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),

              const SizedBox(height: 16),

              // اسم المنتج
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // وصف المنتج
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  product.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),

              const SizedBox(height: 16),

              // التفاصيل الأخرى
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Stock: ${product.stock}", style: const TextStyle(fontSize: 14)),
                    Text("Category: ${product.category}", style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // السعر والتقييم
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          if (index < product.rating.floor()) {
                            return const Icon(Icons.star, color: Colors.orange, size: 20);
                          } else if (index == product.rating.floor() && product.rating % 1 > 0) {
                            return const Icon(Icons.star_half, color: Colors.orange, size: 20);
                          } else {
                            return const Icon(Icons.star_border, color: Colors.orange, size: 20);
                          }
                        }),
                        const SizedBox(width: 4),
                        Text(
                          "(${product.reviews})",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // زر الإضافة إلى السلة
              Obx(() {
                final isInCart = cartController.isInCart(product.id);
                final quantity = cartController.getProductQuantity(product.id);
                
                return Column(
                  children: [
                    if (isInCart) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (quantity > 1) {
                                cartController.updateQuantity(product.id, quantity - 1);
                              } else {
                                cartController.removeFromCart(product.id);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              cartController.updateQuantity(product.id, quantity + 1);
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: product.stock > 0
                          ? () {
                              if (isInCart) {
                                cartController.removeFromCart(product.id);
                              } else {
                                cartController.addToCart(product.id);
                              }
                            }
                          : null,
                      icon: Icon(isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart),
                      label: Text(isInCart ? "Remove from Cart" : "Add to Cart"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
