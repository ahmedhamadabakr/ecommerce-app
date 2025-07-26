import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_store/constent.dart';

// GetX Controller for registration
class RegisterController extends GetxController {
  // Personal Information
  var firstName = ''.obs;
  var lastName = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var address = ''.obs;
  var age = ''.obs;
  var gender = ''.obs;

  // Security Information
  var password = ''.obs;
  var confirmPassword = ''.obs;

  void setPersonalInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String age,
    required String gender,
  }) {
    this.firstName.value = firstName;
    this.lastName.value = lastName;
    this.email.value = email;
    this.phone.value = phone;
    this.address.value = address;
    this.age.value = age;
    this.gender.value = gender;
  }

  void setSecurityInfo({
    required String password,
    required String confirmPassword,
  }) {
    this.password.value = password;
    this.confirmPassword.value = confirmPassword;
  }

  void register() async {
    // Simulate registration process
    await Future.delayed(const Duration(seconds: 2));
    
    Get.snackbar(
      "Success",
      "Account created successfully!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Navigate to login page
    Get.offAllNamed(kLoginPage);
  }
} 