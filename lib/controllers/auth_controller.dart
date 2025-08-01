import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_store/services/api_service.dart';
import 'package:ecommerce_store/controllers/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final int age;
  final String gender;
  final String role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.age,
    required this.gender,
    this.role = 'user',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'age': age,
      'gender': gender,
      'role': role,
    };
  }

  String get fullName => '$firstName $lastName';
}

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final CartController _cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  var user = Rxn<User>();
  var isAuthenticated = false.obs;
  var loading = false.obs;
  var error = ''.obs;
  var token = ''.obs;
  var userId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService.init();
    // Check auth status silently in background
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final isAuthStored = prefs.getBool('isAuthenticated') ?? false;
    final storedUserId = prefs.getString('userId');
    final userJsonString = prefs.getString('user');

    // Check if we have all required data for authentication
    if (storedToken != null && isAuthStored && storedUserId != null) {
      // Set all authentication data
      token.value = storedToken;
      userId.value = storedUserId;
      isAuthenticated.value = true;

      // Configure API service
      _apiService.setToken(token.value);
      _apiService.setUserId(userId.value);

      // Restore user data if available
      if (userJsonString != null) {
        try {
          final userMap = Map<String, dynamic>.from(jsonDecode(userJsonString));
          user.value = User.fromJson(userMap);
        } catch (e) {
          await prefs.remove('user');
        }
      }

      // Set cart authentication status
      _cartController.setAuthenticationStatus(true);
    } else {
      await _clearAuthenticationData();
    }
  }

  Future<void> _clearAuthenticationData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear memory
    isAuthenticated.value = false;
    token.value = '';
    user.value = null;
    userId.value = '';

    // Clear SharedPreferences
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('userId');

    // Clear API service
    _apiService.clearToken();
    _cartController.setAuthenticationStatus(false);
  }

  // Register new user
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required int age,
    required String gender,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      loading.value = true;
      error.value = '';

      // Validate passwords match
      if (password != confirmPassword) {
        error.value = 'Passwords do not match';
        return false;
      }

      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'address': address,
        'age': age,
        'gender': gender,
        'password': password,
      };

      final response = await _apiService.register(userData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'تم التسجيل بنجاح!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        error.value = 'Registration failed';
        return false;
      }
    } catch (e) {
      error.value = 'Registration failed: ${e.toString()}';
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      loading.value = true;
      error.value = '';

      final credentials = {'email': email, 'password': password};
      final response = await _apiService.login(credentials);

      if (response.statusCode == 200) {
        final data = response.data;
        final tokenValue = data['token'];
        final userData = data['user'];

        if (tokenValue != null && userData != null) {
          // Set all authentication data in memory
          token.value = tokenValue;
          user.value = User.fromJson(userData);
          userId.value = user.value!.id;
          isAuthenticated.value = true;

          // Configure API service FIRST
          _apiService.setToken(token.value);
          _apiService.setUserId(userId.value);

          // Save to SharedPreferences with proper error handling
          await _saveAuthenticationData();

          // Set cart authentication status
          _cartController.setAuthenticationStatus(true);

          Get.offAllNamed('/');

          Get.snackbar(
            'تم تسجيل الدخول',
            'أهلًا بك ${user.value!.fullName}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          error.value = 'بيانات المستخدم أو التوكن غير صالحة';
        }
      } else {
        error.value = 'فشل تسجيل الدخول';
      }
    } catch (e) {
      error.value = 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}';
    } finally {
      loading.value = false;
    }
  }

  Future<void> _saveAuthenticationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token.value);
      await prefs.setString('user', jsonEncode(user.value!.toJson()));
      await prefs.setString('userId', userId.value);
      await prefs.setBool('isAuthenticated', true);

    } catch (e) {
      print('❌ Error saving authentication data: $e');
      // Don't throw here, just log the error
    }
  }

  // Remove token and clear authentication
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('userId');
    await prefs.setBool('isAuthenticated', false);

    token.value = '';
    user.value = null;
    userId.value = '';
    isAuthenticated.value = false;

    _apiService.clearToken();
    _cartController.setAuthenticationStatus(false);
  }

  // Logout user
  Future<void> logout() async {
    await removeToken();
    Get.offAllNamed('/login');
  }

  // Get current user
  User? get currentUser => user.value;

  // Check if user is admin
  bool get isAdmin => user.value?.role == 'admin';

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    int? age,
    String? gender,
  }) async {
    try {
      loading.value = true;
      error.value = '';

      if (user.value == null) {
        error.value = 'No user logged in';
        return false;
      }

      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;

      // In a real app, you'd call update profile API
      // final response = await _apiService.updateProfile(updateData);

      // For now, just update local user data
      final updatedUser = User(
        id: user.value!.id,
        firstName: firstName ?? user.value!.firstName,
        lastName: lastName ?? user.value!.lastName,
        email: user.value!.email,
        phone: phone ?? user.value!.phone,
        address: address ?? user.value!.address,
        age: age ?? user.value!.age,
        gender: gender ?? user.value!.gender,
        role: user.value!.role,
      );

      user.value = updatedUser;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      error.value = 'Failed to update profile';
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      loading.value = true;
      error.value = '';

      if (newPassword != confirmPassword) {
        error.value = 'New passwords do not match';
        return false;
      }

      // In a real app, you'd call change password API
      // final response = await _apiService.changePassword({
      //   'currentPassword': currentPassword,
      //   'newPassword': newPassword,
      // });

      Get.snackbar(
        'Success',
        'تم تغيير كلمة المرور بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      error.value = 'Failed to change password';
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Auto login after registration
  Future<bool> autoLoginAfterRegister({
    required String email,
    required String password,
  }) async {
    try {
      loading.value = true;
      error.value = '';

      final credentials = {'email': email, 'password': password};
      final response = await _apiService.login(credentials);

      if (response.statusCode == 200) {
        final data = response.data;
        final tokenValue = data['token'];
        final userData = data['user'];

        if (tokenValue != null && userData != null) {

          // Set all authentication data
          token.value = tokenValue;
          user.value = User.fromJson(userData);
          userId.value = user.value!.id;
          isAuthenticated.value = true;

          // Configure API service
          _apiService.setToken(token.value);
          _apiService.setUserId(userId.value);

          // Save authentication data
          await _saveAuthenticationData();

          // Set cart authentication status
          _cartController.setAuthenticationStatus(true);

          Get.snackbar(
            'Success',
            'تم التسجيل وتسجيل الدخول بنجاح!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          return true;
        } else {
          error.value = 'بيانات المستخدم أو التوكن غير صالحة';
          return false;
        }
      } else {
        error.value = 'Auto login failed';
        return false;
      }
    } catch (e) {
      error.value = 'Auto login failed: ${e.toString()}';
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Clear error
  void clearError() {
    error.value = '';
  }
}
