import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/home_controller.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/screens/detailed_page.dart';
import 'package:room_finder/widgets/fetch_indicator.dart';
import 'package:room_finder/widgets/shimmer_card.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

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
    final HomeController homeController = Get.put(HomeController());
    final LikedController likedController = Get.put(LikedController());

    // Function to refresh all data
    Future<void> refreshAllData() async {
      try {
        await Future.wait<void>([
          homeController.refreshPosts(),
        ]);
      } catch (e) {
        Get.snackbar(
          'Refresh Error',
          'Failed to refresh data',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

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
      body: RefreshIndicator.adaptive(
        color: Colors.green,
        onRefresh: refreshAllData,
        child: Column(
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
                // Handle initial loading state
                if (homeController.isLoading.value &&
                    homeController.rentals.isEmpty) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

                // Apply filters to the rentals
                List<RentalProperty> displayRentals =
                    homeController.applyFilters(homeController.rentals);

                // Handle empty state
                if (displayRentals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No properties found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Clear all filters
                            homeController.clearFilters();
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ],
                    ),
                  );
                }

                // Main grid view with fetch more functionality
                return FetchMoreIndicator(
                  onAction: () => homeController.fetchMorePosts(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive grid column count
                      int crossAxisCount = constraints.maxWidth < 600
                          ? 2
                          : constraints.maxWidth < 900
                              ? 3
                              : 4;

                      return GridView.builder(
                        // Keyboard dismiss behavior
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,

                        // Padding and grid configuration
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 3 / 4,
                        ),

                        // Item count with loading indicator consideration
                        itemCount: displayRentals.length +
                            (homeController.hasMorePosts.value ? 1 : 0),

                        // Item builder
                        itemBuilder: (context, index) {
                          // Handle loading indicator for more posts
                          if (index == displayRentals.length &&
                              homeController.hasMorePosts.value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Loading more properties...',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Get the rental property
                          var rental = displayRentals[index];

                          // Individual rental property card with animation
                          return OpenContainer(
                            transitionType: ContainerTransitionType.fade,
                            openBuilder:
                                (BuildContext context, VoidCallback _) {
                              return DetailedPage(rental: rental);
                            },
                            closedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            closedElevation: 5,
                            closedColor: Theme.of(context).cardColor,
                            closedBuilder: (BuildContext context,
                                VoidCallback openContainer) {
                              return GestureDetector(
                                onTap: openContainer,
                                child: Stack(
                                  children: [
                                    // Main card content (similar to previous implementation)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: [
                                          // Image
                                          Positioned.fill(
                                            child: rental.imageUrls.isNotEmpty
                                                ? Image.network(
                                                    rental.imageUrls[0],
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey[300],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    color: Colors.grey,
                                                    child: const Icon(
                                                      Icons.image,
                                                      size: 50,
                                                    ),
                                                  ),
                                          ),

                                          // Availability Tag
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8),
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

                                          // Like Button
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
                                                  homeController
                                                      .toggleLike(rental);
                                                },
                                              );
                                            }),
                                          ),

                                          // Property Details
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  // The _buildFilterDialog method remains the same as in the previous implementation
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
