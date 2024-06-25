import 'package:flutter/material.dart';
import 'package:room_finder/services/auth/auth_service.dart';
import 'package:room_finder/widgets/my_button.dart';
import 'package:room_finder/widgets/my_textfield.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? onTap;

  LoginPage({Key? key, required this.onTap});

  void login(BuildContext context) async {
    final _authService = AuthService();
    try {
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
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              ),
              const SizedBox(height: 16),
              MyTextField(
                hintText: 'Password',
                obscureText: true,
                controller: _pwController,
              ),
              const SizedBox(height: 24),
              MyButton(
                text: 'Login',
                onTap: () => login(context),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  'Not a member? Register now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
