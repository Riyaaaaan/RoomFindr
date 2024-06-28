import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:room_finder/controllers/home_controller.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/screens/detailed_page.dart';

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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: OpenContainer(
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) => DetailedPage(rental: rental),
                closedShape: const RoundedRectangleBorder(
                  side: BorderSide(width: 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                closedElevation: 3,
                closedColor: Theme.of(context).cardColor,
                closedBuilder: (context, openContainer) => ListTile(
                  onTap: openContainer,
                  contentPadding: const EdgeInsets.all(8),
                  enableFeedback: true,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      rental.imageUrls.isNotEmpty
                          ? rental.imageUrls[0]
                          : 'https://via.placeholder.com/150',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    rental.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
              ),
            );
          },
        );
      }),
    );
  }
}
