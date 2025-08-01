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
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? json['title'] ?? '', // السيرفر يستخدم 'title'
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
      error.value = 'Failed to fetch cart from server: ${e.toString()}';
      cartItems.clear();
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

      // Verify we have valid authentication before proceeding
      final authController = Get.find<AuthController>();
      if (authController.userId.value.isEmpty) {
        throw Exception('User ID is missing - authentication required');
      }

      final response = await _apiService.addToCart(productId, quantity);

      // Check if response is successful
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('API returned status ${response.statusCode}');
      }

      final cartData = response.data;

      // Handle mobile API response format
      if (cartData != null) {
        if (cartData is Map<String, dynamic>) {
          // التحقق من نجاح العملية
          final success = cartData['success'] ?? false;
          final items = cartData['items'] as List? ?? [];

          if (success) {
            cartItems.value = items
                .map((item) => CartItem.fromJson(item))
                .toList();

            // تأكيد إضافي على الحفظ
            if (cartData.containsKey('cart') && cartData['cart'] != null) {
              print(
                '🛒 💾 Cart object saved in database: ${cartData['cart']['_id']}',
              );
            }
          } else {
            // فشل في الحفظ لكن لديك البيانات
            print('🛒 ⚠️ API call succeeded but operation failed');
            if (items.isNotEmpty) {
              cartItems.value = items
                  .map((item) => CartItem.fromJson(item))
                  .toList();
            }
            // fallback لجلب البيانات من السيرفر
            await fetchCart();
          }
        } else if (cartData is List) {
          // تنسيق مباشر
          cartItems.value = cartData
              .map((item) => CartItem.fromJson(item))
              .toList();
        } else {
          await fetchCart();
        }
      } else {
        await fetchCart();
      }

      Get.snackbar(
        '✅ تم الحفظ بنجاح',
        '🗃️ تم إضافة المنتج وحفظه في قاعدة البيانات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ CART ERROR: $e');

      // Show detailed error message
      error.value = 'فشل في إضافة المنتج: ${e.toString()}';

      Get.snackbar(
        '❌ خطأ في السيرفر',
        'فشل في إضافة المنتج للسلة. تحقق من اتصال السيرفر.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
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
      // ✅ تحديث فوري في الـ UI
      final itemIndex = cartItems.indexWhere((item) => item.id == productId);
      if (itemIndex >= 0) {
        // تحديث مؤقت في الـ UI
        cartItems[itemIndex] = CartItem(
          id: cartItems[itemIndex].id,
          name: cartItems[itemIndex].name,
          price: cartItems[itemIndex].price,
          image: cartItems[itemIndex].image,
          quantity: quantity,
        );
        cartItems.refresh();
      }

      loading.value = true;
      error.value = '';

      final response = await _apiService.updateCartItem(productId, quantity);
      final cartData = response.data;

      // ✅ تحديث من السيرفر لضمان التطابق
      if (cartData != null &&
          cartData['success'] == true &&
          cartData['items'] != null) {
        cartItems.value = (cartData['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();

        Get.snackbar(
          '✅ تم التحديث',
          'تم تحديث الكمية في السيرفر',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      // ✅ في حالة الخطأ، أرجع للكمية الأصلية
      print('❌ Failed to update on server: $e');
      await fetchCart(); // إعادة جلب من السيرفر

      error.value = 'Failed to update quantity: ${e.toString()}';
      Get.snackbar(
        '❌ فشل التحديث',
        'حدث خطأ في تحديث الكمية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

    // ✅ حفظ المنتج للإرجاع في حالة الخطأ
    CartItem? itemToRemove;

    try {
      // حفظ المنتج قبل الحذف
      itemToRemove = cartItems.firstWhereOrNull((item) => item.id == productId);

      // ✅ إزالة فورية من الـ UI
      cartItems.removeWhere((item) => item.id == productId);
      cartItems.refresh();

      loading.value = true;
      error.value = '';

      final response = await _apiService.removeFromCart(productId);
      final cartData = response.data;

      // ✅ تحديث من السيرفر لضمان التطابق
      if (cartData != null &&
          cartData['success'] == true &&
          cartData['items'] != null) {
        cartItems.value = (cartData['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      }

      Get.snackbar(
        '✅ تم الحذف',
        'تم حذف المنتج من السلة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // ✅ في حالة الخطأ، أرجع المنتج للسلة
    
      if (itemToRemove != null) {
        cartItems.add(itemToRemove);
        cartItems.refresh();

      }

      error.value = 'Failed to remove product from cart: ${e.toString()}';
      Get.snackbar(
        '❌ فشل الحذف',
        'حدث خطأ في حذف المنتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    } finally {
      loading.value = false;
    }
  }

  int get itemCount {
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return cartItems.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
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
}
