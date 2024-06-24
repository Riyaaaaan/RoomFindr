import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/post_controller.dart';
import 'package:room_finder/screens/detailed_page.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.put(PostController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: Obx(() {
        if (postController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (postController.error.value.isNotEmpty) {
          return Center(
            child: Text('Error: ${postController.error.value}'),
          );
        }

        if (postController.rentals.isEmpty) {
          return const Center(
            child: Text('No posts found.'),
          );
        }

        return ListView.builder(
          itemCount: postController.rentals.length,
          itemBuilder: (context, index) {
            var rental = postController.rentals[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => DetailedPage(rental: rental));
                },
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    tileColor: Colors.grey[200],
                    leading: rental.imageUrls.isNotEmpty
                        ? Image.network(
                            rental.imageUrls[0],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                          ),
                    title: Text(rental.name),
                    subtitle: Text(rental.type),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
