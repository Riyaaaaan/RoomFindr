import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/post_controller.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/screens/detailed_page.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key});

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _showDeleteConfirmation(context, rental.id);
                        },
                        icon: Icons.delete,
                        backgroundColor: Colors.red,
                      )
                    ],
                  ),
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _toggleAvailability(rental);
                        },
                        icon: rental.isAvailable ? Icons.close : Icons.verified,
                        backgroundColor:
                            rental.isAvailable ? Colors.red : Colors.green,
                        label: rental.isAvailable ? 'Unavailable' : 'Available',
                      )
                    ],
                  ),
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
                        // tileColor: Colors.grey[200],
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
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color:
                                rental.isAvailable ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            rental.isAvailable ? 'Available' : 'Unavailable',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                Get.find<PostController>().deletePost(postId);
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleAvailability(RentalProperty rental) {
    rental.isAvailable = !rental.isAvailable;
    if (rental.isAvailable) {
      Get.snackbar(
        'Availability Changed',
        '${rental.name} is now available',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Availability Changed',
        '${rental.name} is now unavailable',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    Get.find<PostController>().updatePostAvailability(rental);
  }
}
