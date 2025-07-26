import 'package:flutter/material.dart';

class ProductItemInCart extends StatelessWidget {
  const ProductItemInCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset("assets/15.png", height: 80, width: 80, fit: BoxFit.cover),
          ),

          const SizedBox(width: 12),

          // تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Title of Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Price: \$22", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 8),

                // تحكم الكمية + حذف
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
                        const Text("1"),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("\$22", style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.delete, color: Colors.red)),
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
