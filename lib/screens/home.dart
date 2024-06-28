import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/home_controller.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:room_finder/controllers/profile_controller.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/screens/detailed_page.dart';
import 'package:room_finder/widgets/shimmer_card.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final List<String> _places = [
    'Kochi',
    'Ernakulam',
    'Aluva',
    'Vytilla',
    'Kakkanad',
  ];
  final List<String> _propertyTypes = ['Apartment', 'House', 'PG'];
  final List<String> _types = ['Rent', 'Lease', 'Sell'];

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    profileController.fetchUserProfile();

    final HomeController homeController = Get.put(HomeController());
    final LikedController likedController = Get.put(LikedController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RoomFindr',
          style: TextStyle(
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(CupertinoIcons.search),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          homeController.search(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.slider_horizontal_3),
                      onPressed: () {
                        Get.dialog(
                          _buildFilterDialog(context, homeController),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (homeController.isLoading.value) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: 6, // Show 6 shimmer cards while loading
                  itemBuilder: (context, index) {
                    return const ShimmerProductCard();
                  },
                );
              }

              List<RentalProperty> displayRentals =
                  homeController.applyFilters(homeController.rentals);

              if (displayRentals.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth < 600
                      ? 2
                      : constraints.maxWidth < 900
                          ? 3
                          : 4;

                  return GridView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: displayRentals.length,
                    itemBuilder: (context, index) {
                      var rental = displayRentals[index];

                      return OpenContainer(
                        transitionType: ContainerTransitionType.fade,
                        openBuilder: (BuildContext context, VoidCallback _) {
                          return DetailedPage(rental: rental);
                        },
                        closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        closedElevation: 5,
                        closedColor: Theme.of(context).cardColor,
                        closedBuilder:
                            (BuildContext context, VoidCallback openContainer) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
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
                                              child: const Icon(Icons.image,
                                                  size: 50),
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
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                        bool isLiked = likedController
                                            .likedRentals
                                            .contains(rental.id);
                                        return IconButton(
                                          icon: Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.white,
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
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDialog(
      BuildContext context, HomeController homeController) {
    List<String> tempSelectedPlaces = List.from(homeController.selectedPlaces);
    List<String> tempSelectedPropertyTypes =
        List.from(homeController.selectedPropertyTypes);
    List<String> tempSelectedTypes = List.from(homeController.selectedTypes);

    return AlertDialog(
      title: const Text('Filter Options'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Place:'),
              Wrap(
                spacing: 8.0,
                children: _places.map((place) {
                  bool isSelected = tempSelectedPlaces.contains(place);
                  return FilterChip(
                    selectedColor: Colors.green,
                    checkmarkColor: Colors.white,
                    label: Text(place),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          tempSelectedPlaces.add(place);
                        } else {
                          tempSelectedPlaces.remove(place);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              const Text('Property Types:'),
              Wrap(
                spacing: 8.0,
                children: _propertyTypes.map((type) {
                  bool isSelected = tempSelectedPropertyTypes.contains(type);
                  return FilterChip(
                    selectedColor: Colors.green,
                    checkmarkColor: Colors.white,
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          tempSelectedPropertyTypes.add(type);
                        } else {
                          tempSelectedPropertyTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              const Text('Types:'),
              Wrap(
                spacing: 8.0,
                children: _types.map((type) {
                  bool isSelected = tempSelectedTypes.contains(type);
                  return FilterChip(
                    selectedColor: Colors.green,
                    checkmarkColor: Colors.white,
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          tempSelectedTypes.add(type);
                        } else {
                          tempSelectedTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            tempSelectedPlaces.clear();
            tempSelectedPropertyTypes.clear();
            tempSelectedTypes.clear();
            homeController.clearFilters();
            Get.back();
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () {
            homeController.selectedPlaces.assignAll(tempSelectedPlaces);
            homeController.selectedPropertyTypes
                .assignAll(tempSelectedPropertyTypes);
            homeController.selectedTypes.assignAll(tempSelectedTypes);
            Get.back();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
