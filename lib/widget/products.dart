import 'package:ecommerce_store/constent.dart';
import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/product_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_store/controllers/products_controller.dart';

class Products extends StatelessWidget {
  const Products({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductsController productsController = Get.find<ProductsController>();
    
    return Column(
      children: [
        CustomAppbar(),
        Expanded(
          child: Obx(() {
            if (productsController.loading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (productsController.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${productsController.error.value}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () => productsController.refreshProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (productsController.filteredProducts.isEmpty) {
              return const Center(
                child: Text(
                  'No products found',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () => productsController.refreshProducts(),
              child: ListView.builder(
                itemCount: productsController.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = productsController.filteredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(kProductDetilRoute, arguments: product);
                    },
                    child: ProductItem(product: product),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
