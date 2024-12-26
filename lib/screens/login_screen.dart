import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/profile_controller.dart';
import 'package:room_finder/services/auth/auth_service.dart';
import 'package:room_finder/widgets/my_button.dart';
import 'package:room_finder/widgets/my_textfield.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? onTap;

  LoginPage({Key? key, required this.onTap});

  final _formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;

  void login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final _authService = AuthService();
    try {
      isLoading.value = true;
      await _authService.signInWithEmailPassword(
          _emailController.text, _pwController.text);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void signInWithGoogle(BuildContext context) async {
    final _authService = AuthService();
    try {
      isGoogleLoading.value = true;
      await _authService.signInWithGoogle();
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchUserProfile();
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Google Sign In Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailValidator = MultiValidator([
      RequiredValidator(errorText: 'Email is required'),
      EmailValidator(errorText: 'Enter a valid email address'),
    ]);

    final passwordValidator =
        RequiredValidator(errorText: 'Password is required');

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.message,
                      size: 60,
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    MyTextField(
                      hintText: 'Email',
                      obscureText: false,
                      controller: _emailController,
                      validator: emailValidator,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hintText: 'Password',
                      obscureText: true,
                      controller: _pwController,
                      validator: passwordValidator,
                    ),
                    const SizedBox(height: 24),
                    Obx(() => isLoading.value
                        ? const CircularProgressIndicator()
                        : MyButton(
                            text: 'Login',
                            onTap: () => login(context),
                          )),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => signInWithGoogle(context),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                              height: 32,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        'Not a member? Register now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading overlay for Google Sign-In
          Obx(() => isGoogleLoading.value
              ? Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 100), // Adjust this value as needed
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Signing in with Google...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }
}
