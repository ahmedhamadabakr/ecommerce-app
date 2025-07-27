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
  final CartController _cartController = Get.isRegistered<CartController>() ? Get.find<CartController>() : Get.put(CartController());

  var user = Rxn<User>();
  var isAuthenticated = false.obs;
  var loading = false.obs;
  var error = ''.obs;
  var token = ''.obs;
  var userId = ''.obs;

  @override
  void onInit() {
    print('=== AUTH CONTROLLER ONINIT ===');
    super.onInit();
    _apiService.init();
    print('API service initialized');
    checkAuthStatus();
    print('checkAuthStatus called');
  }

  Future<void> checkAuthStatus() async {
    print('=== CHECK AUTH STATUS START ===');
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final isAuthStored = prefs.getBool('isAuthenticated') ?? false;

    print('Checking auth status...');
    print('Stored token: $storedToken');
    print('Is auth stored: $isAuthStored');

    if (storedToken != null && isAuthStored) {
      print('Token found and auth is stored, setting up authentication...');
      token.value = storedToken;
      _apiService.setToken(token.value);
      isAuthenticated.value = true;

      // استعادة بيانات المستخدم لو مخزنة
      final userJsonString = prefs.getString('user');
      final storedUserId = prefs.getString('userId');
      
      if (userJsonString != null) {
        try {
          final userMap = Map<String, dynamic>.from(jsonDecode(userJsonString));
          user.value = User.fromJson(userMap);
          print('User data restored: ${user.value?.fullName}');
        } catch (e) {
          print('Error parsing user data: $e');
          // Clear invalid user data
          await prefs.remove('user');
        }
      }
      
      if (storedUserId != null) {
        userId.value = storedUserId;
        print('User ID restored: ${userId.value}');
        _apiService.setUserId(userId.value);
      }

      _cartController.setAuthenticationStatus(true);
      print('Authentication setup complete');
    } else {
      print('No valid token found, clearing authentication...');
      isAuthenticated.value = false;
      // Clear authentication status from SharedPreferences
      await prefs.setBool('isAuthenticated', false);
      await prefs.remove('token');
      await prefs.remove('user');
    }
    print('=== CHECK AUTH STATUS END ===');
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

  // Login user
  Future<bool> login({required String email, required String password}) async {
    print('=== LOGIN START ===');
    print('Email: $email');
    try {
      loading.value = true;
      error.value = '';

      final credentials = {'email': email, 'password': password};

      final response = await _apiService.login(credentials);
      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;

        if (data['token'] != null) {
          token.value = data['token'];
          print('Received token from server: ${token.value}');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token.value);
          print('Token saved to SharedPreferences');
          _apiService.setToken(token.value);
          print('Token set in API service');
        } else {
          print('No token received from server');
        }

        if (data['user'] != null) {
          user.value = User.fromJson(data['user']);
          print('User data received: ${user.value?.fullName}');
          
          // حفظ معرف المستخدم
          userId.value = user.value!.id;
          print('User ID: ${userId.value}');
          _apiService.setUserId(userId.value);

          // حفظ بيانات المستخدم
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(user.value!.toJson()));
          await prefs.setString('userId', userId.value);
          print('User data saved to SharedPreferences');
        }

        isAuthenticated.value = true;
        await _saveAuthStatus(true);
        print('Authentication status saved');
        _cartController.setAuthenticationStatus(true);

        Get.snackbar(
          'Success',
          'تم تسجيل الدخول بنجاح!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        print('=== LOGIN SUCCESS ===');
        return true;
      } else {
        print('Login failed with status: ${response.statusCode}');
        error.value = 'Login failed';
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      error.value = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      loading.value = false;
      print('=== LOGIN END ===');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      await prefs.remove('userId');
      await prefs.setBool('isAuthenticated', false);

      user.value = null;
      isAuthenticated.value = false;
      token.value = '';
      userId.value = '';
      _cartController.setAuthenticationStatus(false);
      Get.snackbar(
        'Success',
        'تم تسجيل الخروج بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      // Navigate to home
      Get.offAllNamed('/');
    } catch (e) {
      print('Logout error: $e');
    }
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
      print('Update profile error: $e');
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
      print('Change password error: $e');
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

        if (data['token'] != null) {
          token.value = data['token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token.value);
          _apiService.setToken(token.value);
        }

        if (data['user'] != null) {
          user.value = User.fromJson(data['user']);

          // حفظ بيانات المستخدم
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(user.value!.toJson()));
        }

        isAuthenticated.value = true;
        await _saveAuthStatus(true);
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

  // Save authentication status to SharedPreferences
  Future<void> _saveAuthStatus(bool status) async {
    print('=== SAVE AUTH STATUS ===');
    print('Status to save: $status');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', status);
    print('Authentication status saved to SharedPreferences: $status');
  }

  // Clear error
  void clearError() {
    error.value = '';
  }
}
