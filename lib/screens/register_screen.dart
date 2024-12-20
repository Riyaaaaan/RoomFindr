import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/services/auth/auth_service.dart';
import 'package:room_finder/widgets/my_button.dart';
import 'package:room_finder/widgets/my_textfield.dart';
import 'package:form_field_validator/form_field_validator.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final void Function()? onTap;

  RegisterPage({Key? key, required this.onTap}) : super(key: key);

  final RxBool _isLoading = false.obs;

  final _formKey = GlobalKey<FormState>();

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    final _auth = AuthService();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _pwController.text.trim();
    final confirmPassword = _confirmpwController.text.trim();

    if (password != confirmPassword) {
      showErrorDialog("Passwords do not match");
      return;
    }

    _isLoading.value = true;

    try {
      await _auth.signUpWithEmailPassword(email, password, name);
      Get.snackbar(
        'Success',
        'Registration Successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      showErrorDialog(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  void showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Get.back(); // Dismiss the dialog
            },
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Get.back(); // Dismiss the dialog
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameValidator = MultiValidator([
      RequiredValidator(errorText: 'Name is required'),
      MinLengthValidator(3,
          errorText: 'Name must be at least 3 characters long'),
    ]);

    final emailValidator = MultiValidator([
      RequiredValidator(errorText: 'Email is required'),
      EmailValidator(errorText: 'Enter a valid email address'),
    ]);

    final passwordValidator = MultiValidator([
      RequiredValidator(errorText: 'Password is required'),
      MinLengthValidator(8,
          errorText: 'Password must be at least 8 characters long'),
      PatternValidator(r'(?=.*?[a-zA-Z])',
          errorText: 'Password must contain at least one letter'),
      PatternValidator(r'(?=.*?[0-9])',
          errorText: 'Password must contain at least one number'),
      PatternValidator(r'(?=.*?[!@#$%^&*()_+])',
          errorText: 'Password must contain at least one special character'),
    ]);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.message,
                  size: 60,
                  color: theme.iconTheme.color,
                ),
                const SizedBox(height: 50),
                Text(
                  "Let's create an account for you",
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  hintText: 'Name',
                  obscureText: false,
                  controller: _nameController,
                  validator: nameValidator,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                MyTextField(
                  hintText: 'Confirm Password',
                  obscureText: true,
                  controller: _confirmpwController,
                  validator: (val) =>
                      MatchValidator(errorText: 'Passwords do not match')
                          .validateMatch(val!, _pwController.text),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => MyButton(
                    text: 'Register',
                    onTap: _isLoading.value ? null : register,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Already have an account? Login now',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
