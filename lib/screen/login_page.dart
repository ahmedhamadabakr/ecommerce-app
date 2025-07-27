import 'package:ecommerce_store/constent.dart';
import 'package:ecommerce_store/widget/custom_button.dart';
import 'package:ecommerce_store/widget/custom_text_field.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_store/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  AuthController authController = Get.find<AuthController>();



  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // إخفاء الكيبورد
      child: Scaffold(
        drawer: const OpenDrawer(),
        backgroundColor: kPrimaryColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: globalKey,
              child: ListView(
                children: [
                  const SizedBox(height: 80),

                  Image.asset(
                    "assets/favicon.png",
                    height: 100,
                    color: Colors.white,
                  ),

                  Center(
                    child: Text(
                      "Ecommerce Store",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  const Text(
                    "LOGIN",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),

                  const SizedBox(height: 15),

                  CustomFormTextField(
                    controller: emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  CustomFormTextField(
                    controller: passwordController,
                    obscureText: true,
                    hintText: "Password",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  Obx(() => authController.loading.value
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : CustomButton(
                          btnText: "LOGIN",
                          onTab: () async {
                            if (globalKey.currentState!.validate()) {
                              final success = await authController.login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              
                              if (success) {
                                // Navigate to home page after successful login
                                await Future.delayed(Duration(milliseconds: 500));
                                Get.offAllNamed('/');
                              }
                            }
                          },
                        )),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don’t have an account?",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(kRegisterPage),
                        child: const Text(
                          " Register",
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
