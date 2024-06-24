import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/liked_controller.dart'; // Import your LikedController
import 'package:room_finder/controllers/home_controller.dart'; // Import your HomeController
import 'package:room_finder/models/post_model.dart';

class LikedPage extends StatelessWidget {
  final LikedController likedController = Get.put(LikedController());
  final HomeController homeController = Get.put(HomeController());

  LikedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Posts'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (likedController.likedRentals.isEmpty) {
          return const Center(
            child: Text('You have not liked posts.'),
          );
        }

        List<RentalProperty> likedRentals = homeController.rentals
            .where((rental) => likedController.likedRentals.contains(rental.id))
            .toList();

        if (likedRentals.isEmpty) {
          return const Center(
            child: Text('No liked rentals found.'),
          );
        }

        return ListView.builder(
          itemCount: likedRentals.length,
          itemBuilder: (context, index) {
            var rental = likedRentals[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    rental.imageUrls.isNotEmpty
                        ? rental.imageUrls[0]
                        : 'https://via.placeholder.com/150',
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(rental.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₹${rental.price}'),
                    Text(rental.type),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    likedController.toggleLike(rental);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
