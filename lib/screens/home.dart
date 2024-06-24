import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/home_controller.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/screens/detailed_page.dart';
import 'package:room_finder/services/auth/auth_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());
    final LikedController likedController = Get.put(LikedController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoomFindr'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.offAll(const AuthPage());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    homeController.search(value);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (homeController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              List<RentalProperty> displayRentals =
                  homeController.rentals.where((rental) {
                return rental.name
                    .toLowerCase()
                    .contains(homeController.searchQuery.value.toLowerCase());
              }).toList();

              if (displayRentals.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: displayRentals.length,
                itemBuilder: (context, index) {
                  var rental = displayRentals[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => DetailedPage(rental: rental));
                    },
                    child: Stack(
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: rental.imageUrls.isNotEmpty
                                      ? Image.network(
                                          rental.imageUrls[0],
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey,
                                          child:
                                              const Icon(Icons.image, size: 50),
                                        ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: rental.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      rental.isAvailable
                                          ? 'Available'
                                          : 'Unavailable',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Obx(() {
                                    bool isLiked = likedController.likedRentals
                                        .contains(rental.id);
                                    return IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isLiked ? Colors.red : Colors.white,
                                      ),
                                      onPressed: () {
                                        homeController.toggleLike(rental);
                                      },
                                    );
                                  }),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rental.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${rental.price}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              rental.type,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
