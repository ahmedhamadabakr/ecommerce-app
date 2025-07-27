import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_store/services/api_service.dart';
import 'package:ecommerce_store/controllers/auth_controller.dart';

import 'package:ecommerce_store/constent.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }
}

class CartController extends GetxController {
  final ApiService _apiService = ApiService();

  var cartItems = <CartItem>[].obs;
  var loading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService.init();
  }

  @override
  void onReady() {
    super.onReady();
    final authController = Get.find<AuthController>();
    if (authController.isAuthenticated.value) {
      fetchCart();
    }
  }

  Future<void> fetchCart() async {
    final authController = Get.find<AuthController>();
    if (!authController.isAuthenticated.value) {
      cartItems.clear();
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      final response = await _apiService.getCart();
      final cartData = response.data;

      if (cartData['items'] != null) {
        cartItems.value = (cartData['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      } else {
        cartItems.clear();
      }
    } catch (e) {
      // If cart API fails, load from local storage instead
      if (e.toString().contains('401')) {
        print('⚠️ Cart API unavailable, using local cart storage');
        await _loadLocalCart();
        error.value = '';
      } else {
        error.value = 'Failed to fetch cart';
        cartItems.clear();
        print('Error fetching cart: $e');
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    final authController = Get.find<AuthController>();
    if (!authController.isAuthenticated.value) {
      error.value = 'يجب تسجيل الدخول أولاً';
      Get.snackbar(
        'مطلوب تسجيل الدخول',
        'يرجى تسجيل الدخول لإضافة منتجات إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.toNamed(kLoginPage);
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      final response = await _apiService.addToCart(productId, quantity);
      final cartData = response.data;

      if (cartData['items'] != null) {
        cartItems.value = (cartData['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      }

      Get.snackbar(
        'Success',
        'تم إضافة المنتج إلى السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (e.toString().contains('401')) {
        // API cart failed, use local cart instead
        print('⚠️ Cart API failed, using local cart for product: $productId');
        await _addToLocalCart(productId, quantity);
        error.value = '';
      } else {
        error.value = 'Failed to add product to cart';
        Get.snackbar(
          'خطأ',
          'فشل في إضافة المنتج للسلة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Error adding to cart: $e');
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final authController = Get.find<AuthController>();
    if (!authController.isAuthenticated.value) {
      error.value = 'Authentication required';
      Get.snackbar(
        'Authentication Required',
        'Please login to update cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.toNamed(kLoginPage);
      return;
    }

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      final response = await _apiService.updateCartItem(productId, quantity);
      final cartData = response.data;

      if (cartData['items'] != null) {
        cartItems.value = (cartData['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        // API failed, update local cart instead
        print('⚠️ API unavailable, updating local cart for product: $productId');
        await _updateLocalCartQuantity(productId, quantity);
        error.value = '';
      } else {
        error.value = 'Failed to update quantity';
        print('Error updating quantity: $e');
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> removeFromCart(String productId) async {
    final authController = Get.find<AuthController>();
    if (!authController.isAuthenticated.value) {
      error.value = 'Authentication required';
      Get.snackbar(
        'Authentication Required',
        'Please login to remove items from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.toNamed(kLoginPage);
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      final response = await _apiService.removeFromCart(productId);
      final cartData = response.data;

      if (cartData['items'] != null) {
        cartItems.value = (cartData['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      }

      Get.snackbar(
        'Success',
        'Product removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (e.toString().contains('401')) {
        // API failed, remove from local cart instead
        print('⚠️ API unavailable, removing from local cart for product: $productId');
        await _removeFromLocalCart(productId);
        error.value = '';
        Get.snackbar(
          'Success',
          'Product removed from cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        error.value = 'Failed to remove product from cart';
        print('Error removing from cart: $e');
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> clearCart() async {
    final authController = Get.find<AuthController>();
    if (!authController.isAuthenticated.value) {
      error.value = 'Authentication required';
      Get.snackbar(
        'Authentication Required',
        'Please login to clear cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      Get.toNamed(kLoginPage);
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      await _apiService.clearCart();
      cartItems.clear();

      Get.snackbar(
        'Success',
        'Cart cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = 'Failed to clear cart';
      print('Error clearing cart: $e');
    } finally {
      loading.value = false;
    }
  }

  int get itemCount {
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }

  bool isInCart(String productId) {
    return cartItems.any((item) => item.id == productId);
  }

  int getProductQuantity(String productId) {
    final item = cartItems.firstWhereOrNull((item) => item.id == productId);
    return item?.quantity ?? 0;
  }

  void setAuthenticationStatus(bool status) {
    if (status) {
      fetchCart();
    } else {
      cartItems.clear();
    }
  }

  Future<void> refreshCart() async {
    await fetchCart();
  }

  // Local cart storage methods
  Future<void> _loadLocalCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('local_cart');
      if (cartJson != null) {
        final List<dynamic> cartList = jsonDecode(cartJson);
        cartItems.value = cartList.map((item) => CartItem.fromJson(item)).toList();
        print('🛒 Loaded ${cartItems.length} items from local cart');
      } else {
        cartItems.clear();
      }
    } catch (e) {
      print('Error loading local cart: $e');
      cartItems.clear();
    }
  }

  Future<void> _saveLocalCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(cartItems.map((item) => item.toJson()).toList());
      await prefs.setString('local_cart', cartJson);
      print('🛒 Saved ${cartItems.length} items to local cart');
    } catch (e) {
      print('Error saving local cart: $e');
    }
  }

  Future<void> _addToLocalCart(String productId, int quantity) async {
    try {
      final existingIndex = cartItems.indexWhere((item) => item.id == productId);
      
      if (existingIndex >= 0) {
        // Update existing item quantity
        final existingItem = cartItems[existingIndex];
        cartItems[existingIndex] = CartItem(
          id: existingItem.id,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity + quantity,
          image: existingItem.image,
        );
      } else {
        // Add new item - simplified version
        cartItems.add(CartItem(
          id: productId,
          name: 'منتج مضاف محلياً',
          price: 0.0,
          quantity: quantity,
          image: '',
        ));
      }
      
      cartItems.refresh();
      await _saveLocalCart();
      
      Get.snackbar(
        'تم بنجاح',
        'تم إضافة المنتج إلى السلة محلياً',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding to local cart: $e');
    }
  }

  Future<void> _updateLocalCartQuantity(String productId, int newQuantity) async {
    try {
      final index = cartItems.indexWhere((item) => item.id == productId);
      if (index >= 0) {
        if (newQuantity > 0) {
          final existingItem = cartItems[index];
          cartItems[index] = CartItem(
            id: existingItem.id,
            name: existingItem.name,
            price: existingItem.price,
            quantity: newQuantity,
            image: existingItem.image,
          );
        } else {
          cartItems.removeAt(index);
        }
        cartItems.refresh();
        await _saveLocalCart();
      }
    } catch (e) {
      print('Error updating local cart quantity: $e');
    }
  }

  Future<void> _removeFromLocalCart(String productId) async {
    try {
      cartItems.removeWhere((item) => item.id == productId);
      cartItems.refresh();
      await _saveLocalCart();
    } catch (e) {
      print('Error removing from local cart: $e');
    }
  }
}
