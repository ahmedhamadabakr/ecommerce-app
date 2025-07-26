import 'package:ecommerce_store/constent.dart';
import 'package:ecommerce_store/widget/custom_appbar.dart';
import 'package:ecommerce_store/widget/product_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Products extends StatelessWidget {
  const Products({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed(kProductDetilRoute);
                },
                child: ProductItem(),
              );
            },
          ),
        ),
      ],
    );
  }
}
