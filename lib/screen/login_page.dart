import 'package:ecommerce_store/constent.dart';
import 'package:ecommerce_store/widget/custom_button.dart';
import 'package:ecommerce_store/widget/custom_text_field.dart';
import 'package:ecommerce_store/widget/open_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool isLoading = false;

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
                    hintText: "Email",
                    onchange: (data) => email = data,
                  ),

                  const SizedBox(height: 10),

                  CustomFormTextField(
                    obscureText: true,
                    hintText: "Password",
                    onchange: (data) => password = data,
                  ),

                  const SizedBox(height: 20),

                  isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : CustomButton(
                          btnText: "LOGIN",
                          onTab: () async {
                            if (globalKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              
                              await Future.delayed(const Duration(seconds: 2)); // محاكاة انتظار API

                              setState(() => isLoading = false);

                              // استكمال تسجيل الدخول
                              Get.snackbar("Success", "Logged in successfully",
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white);
                            }
                          },
                        ),

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
