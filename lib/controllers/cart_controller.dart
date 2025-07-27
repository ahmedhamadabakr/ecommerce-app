import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
    // Initialize API service
    _apiService.init();
    
    // Wait for AuthController to be available and then check authentication status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final authController = Get.find<AuthController>();
        // Check authentication status and fetch cart
        fetchCart();
      } catch (e) {
        print('AuthController not found yet, will retry later');
        // Retry after a short delay
        Future.delayed(Duration(milliseconds: 100), () {
          onInit();
        });
      }
    });
  }

  // Fetch cart from backend
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
      error.value = 'Failed to fetch cart';
      cartItems.clear();
      print('Error fetching cart: $e');
    } finally {
      loading.value = false;
    }
  }

  // Add product to cart
  Future<void> addToCart(String productId, {int quantity = 1}) async {
    print('=== ADD TO CART DEBUG START ===');
    print('Product ID: $productId');
    print('Quantity: $quantity');
    
    final authController = Get.find<AuthController>();
    print('AuthController found: ${authController != null}');
    print('Is authenticated: ${authController.isAuthenticated.value}');
    print('Current token: ${authController.token.value}');
    
    if (!authController.isAuthenticated.value) {
      print('User not authenticated, redirecting to login');
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

    print('Adding to cart with token: ${authController.token.value}');
    print('User authenticated: ${authController.isAuthenticated.value}');

    try {
      loading.value = true;
      error.value = '';
      
      print('Making API call to add to cart...');
      final response = await _apiService.addToCart(productId, quantity);
      print('API call successful: ${response.statusCode}');
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
      print('=== ADD TO CART ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      error.value = 'Failed to add product to cart';
      print('Error adding to cart: $e');
    } finally {
      loading.value = false;
      print('=== ADD TO CART DEBUG END ===');
    }
  }

  // Update product quantity in cart
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
      error.value = 'Failed to update quantity';
      print('Error updating quantity: $e');
    } finally {
      loading.value = false;
    }
  }

  // Remove product from cart
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
      error.value = 'Failed to remove product from cart';
      print('Error removing from cart: $e');
    } finally {
      loading.value = false;
    }
  }

  // Clear entire cart
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

  // Calculate total items in cart
  int get itemCount {
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }

  // Calculate total price
  double get totalPrice {
    return cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return cartItems.any((item) => item.id == productId);
  }

  // Get product quantity in cart
  int getProductQuantity(String productId) {
    final item = cartItems.firstWhereOrNull((item) => item.id == productId);
    return item?.quantity ?? 0;
  }

  // Set authentication status
  void setAuthenticationStatus(bool status) {
    if (status) {
      fetchCart();
    } else {
      cartItems.clear();
    }
  }

  // Refresh cart
  Future<void> refreshCart() async {
    await fetchCart();
  }
} 