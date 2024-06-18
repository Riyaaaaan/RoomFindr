import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/screens/add_post.dart';

class AddPost extends StatelessWidget {
  const AddPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingActionButton.large(
          onPressed: () {
            Get.to(() => const AddPostPage());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
