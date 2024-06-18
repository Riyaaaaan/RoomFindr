import 'package:flutter/material.dart';
import 'package:room_finder/services/auth/auth_service.dart';
import 'package:room_finder/widgets/my_button.dart';
import 'package:room_finder/widgets/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  void register(BuildContext context) {
    final _auth = AuthService();
    final name = _nameController.text; // Get the user's name
    final password = _pwController.text;
    final confirmPassword = _confirmpwController.text;

    // Password validation regex pattern
    final RegExp passwordPattern = RegExp(
      r'^(?=.*?[a-zA-Z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+]).{8,}$',
    );

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match"),
        ),
      );
      return;
    }

    if (!passwordPattern.hasMatch(password)) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text(
            "Password must contain at least 1 letter, 1 number, 1 special character, and be at least 8 characters long",
          ),
        ),
      );
      return;
    }

    try {
      _auth.signUpwithEmailPassword(
        _emailController.text,
        password,
        name, // Pass the user's name here
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 50),
              //welcome
              Text(
                "Let's create an account for you",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              //name txt
              MyTextField(
                hintText: 'Name',
                obscureText: false,
                controller: _nameController,
              ),

              const SizedBox(height: 10),
              //email txt
              MyTextField(
                hintText: 'Email',
                obscureText: false,
                controller: _emailController,
              ),

              const SizedBox(height: 10),
              //pw txt
              MyTextField(
                hintText: 'Password',
                obscureText: true,
                controller: _pwController,
              ),

              const SizedBox(height: 10),
              //confirm pw txt
              MyTextField(
                hintText: 'Confirm Password',
                obscureText: true,
                controller: _confirmpwController,
              ),

              const SizedBox(height: 25),
              //login btn
              MyButton(
                text: 'Register',
                onTap: () => register(context),
              ),

              const SizedBox(height: 25),

              //register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Login now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
