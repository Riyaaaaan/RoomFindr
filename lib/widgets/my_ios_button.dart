import 'package:flutter/material.dart';

class IosButton extends StatelessWidget {
  const IosButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back_ios),
    );
  }
}
