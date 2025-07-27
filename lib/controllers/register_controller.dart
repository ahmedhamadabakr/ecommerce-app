import 'package:get/get.dart';
import 'package:ecommerce_store/controllers/auth_controller.dart';

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
    // Get auth controller
    final authController = Get.find<AuthController>();
    
    // Call auth controller register method
    final success = await authController.register(
      firstName: firstName.value,
      lastName: lastName.value,
      email: email.value,
      phone: phone.value,
      address: address.value,
      age: int.tryParse(age.value) ?? 0,
      gender: gender.value,
      password: password.value,
      confirmPassword: confirmPassword.value,
    );
    
    if (success) {
      // After successful registration, automatically login the user
      final loginSuccess = await authController.autoLoginAfterRegister(
        email: email.value,
        password: password.value,
      );
      
      if (loginSuccess) {
        // Navigate to home page
        await Future.delayed(Duration(milliseconds: 500));
        Get.offAllNamed('/');
      } else {
        // If auto-login fails, navigate to login page
        Get.offAllNamed('/login');
      }
    }
  }
} 