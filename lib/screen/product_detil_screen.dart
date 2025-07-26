import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:flutter/material.dart';

class ProductDetilScreen extends StatelessWidget {
  const ProductDetilScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset("assets/15.png", height: 300, fit: BoxFit.cover),
              ),

              const SizedBox(height: 16),

              // اسم المنتج
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Text(
                      "Product Name",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // وصف المنتج
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "This is a detailed description of the product that tells users about features, usage, and quality.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),

              const SizedBox(height: 16),

              // التفاصيل الأخرى
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Quantity: 3", style: TextStyle(fontSize: 14)),
                    Text("Color: Red", style: TextStyle(fontSize: 14)),
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
                    const Text(
                      "\$99.99",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        Icon(Icons.star_half, color: Colors.orange, size: 20),
                        Icon(Icons.star_border, color: Colors.orange, size: 20),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // زر الإضافة إلى السلة
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add to Cart"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
