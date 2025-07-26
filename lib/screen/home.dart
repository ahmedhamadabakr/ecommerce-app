import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:ecommerce_store/widget/products.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(drawer: OpenDrawer(), body: Products());
  }
}
