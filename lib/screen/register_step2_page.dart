import 'package:ecommerce_store/constent.dart';
import 'package:ecommerce_store/widget/custom_button.dart';
import 'package:ecommerce_store/widget/custom_text_field.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_store/controllers/register_controller.dart';

class RegisterStep2Page extends StatefulWidget {
  const RegisterStep2Page({super.key});
  static String id = 'RegisterStep2Page';

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  // Form controllers for second page
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late RegisterController registerController;

  @override
  void initState() {
    super.initState();
    registerController = Get.find<RegisterController>();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        drawer: const OpenDrawer(),
        backgroundColor: kPrimaryColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 40),

                  Image.asset(
                    "assets/favicon.png",
                    height: 80,
                    color: Colors.white,
                  ),

                  const Center(
                    child: Text(
                      "Ecommerce Store",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Register - Step 2",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Security Information",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // Progress indicator
                  LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // User info summary
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information Summary:",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(() => Text(
                          "${registerController.firstName.value} ${registerController.lastName.value}",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        )),
                        Obx(() => Text(
                          registerController.email.value,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        )),
                        Obx(() => Text(
                          "Age: ${registerController.age.value} | ${registerController.gender.value}",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password
                  CustomFormTextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Confirm Password
                  CustomFormTextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    hintText: "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          btnText: "Back",
                          onTab: () {
                            Get.back();
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            : CustomButton(
                                btnText: "Register",
                                onTab: () {
                                  if (formKey.currentState!.validate()) {
                                    setState(() => isLoading = true);
                                    
                                    // Store security info in GetX controller
                                    registerController.setSecurityInfo(
                                      password: passwordController.text,
                                      confirmPassword: confirmPasswordController.text,
                                    );
                                    
                                    // Complete registration
                                    registerController.register();
                                  }
                                },
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(kLoginPage),
                        child: const Text(
                          " Login",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xffC7EDE6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 