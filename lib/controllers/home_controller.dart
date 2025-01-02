import 'dart:developer';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:room_finder/models/post_model.dart';

class HomeController extends GetxController {
  var rentals = <RentalProperty>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  // Selected filter options (using RxList for reactivity)
  var selectedPlaces = <String>[].obs;
  var selectedPropertyTypes = <String>[].obs;
  var selectedTypes = <String>[].obs;

  // LikedController instance
  LikedController likedController = Get.find();

  @override
  void onInit() {
    super.onInit();
    // Initially load posts, but don't set up a live listener
    loadInitialPosts();
  }

  Future<void> loadInitialPosts() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rentalProperties')
          .orderBy('createdAt', descending: true)
          .get();

      rentals.value = snapshot.docs.map((doc) {
        return RentalProperty.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      isLoading.value = false;
    } catch (e) {
      log('Error loading initial posts: $e');
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    try {
      isLoading.value = true;

      // Fetch the latest posts
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rentalProperties')
          .orderBy('createdAt', descending: true)
          .get();

      // Update the rentals list with the latest data
      rentals.value = snapshot.docs.map((doc) {
        return RentalProperty.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      isLoading.value = false;
    } catch (e) {
      log('Error refreshing posts: $e');
      isLoading.value = false;
    }
  }

  // Rest of the existing methods remain the same
  void search(String query) {
    searchQuery.value = query;
  }

  void toggleLike(RentalProperty rental) async {
    await likedController.toggleLike(rental);
  }

  List<RentalProperty> applyFilters(List<RentalProperty> properties) {
    return properties.where((rental) {
      final nameMatches =
          rental.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      final placeMatches =
          selectedPlaces.isEmpty || selectedPlaces.contains(rental.place);
      final propertyTypeMatches = selectedPropertyTypes.isEmpty ||
          selectedPropertyTypes.contains(rental.propertyType);
      final typeMatches =
          selectedTypes.isEmpty || selectedTypes.contains(rental.type);

      return nameMatches && placeMatches && propertyTypeMatches && typeMatches;
    }).toList();
  }

  void clearFilters() {
    selectedPlaces.clear();
    selectedPropertyTypes.clear();
    selectedTypes.clear();
  }
}
