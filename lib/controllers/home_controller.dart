import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:room_finder/models/post_model.dart';

class HomeController extends GetxController {
  var rentals = <RentalProperty>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var hasMorePosts = true.obs;

  // Pagination variables
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 10;

  // Selected filter options (using RxList for reactivity)
  var selectedPlaces = <String>[].obs;
  var selectedPropertyTypes = <String>[].obs;
  var selectedTypes = <String>[].obs;

  // LikedController instance
  LikedController likedController = Get.find();

  @override
  void onInit() {
    super.onInit();
    loadInitialPosts();
  }

  Future<void> loadInitialPosts() async {
    try {
      isLoading.value = true;
      hasMorePosts.value = true;
      rentals.clear();
      _lastDocument = null;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rentalProperties')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        rentals.value = snapshot.docs.map((doc) {
          return RentalProperty.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      }

      hasMorePosts.value = snapshot.docs.length == _pageSize;
      isLoading.value = false;
    } catch (e) {
      log('Error loading initial posts: $e');
      isLoading.value = false;
      hasMorePosts.value = false;
    }
  }

  Future<void> fetchMorePosts() async {
    if (!hasMorePosts.value || isLoading.value) return;

    try {
      isLoading.value = true;

      // Base query
      Query query = FirebaseFirestore.instance
          .collection('rentalProperties')
          .orderBy('createdAt', descending: true);

      // Apply filters if any
      if (selectedPlaces.isNotEmpty) {
        query = query.where('place', whereIn: selectedPlaces);
      }
      if (selectedPropertyTypes.isNotEmpty) {
        query = query.where('propertyType', whereIn: selectedPropertyTypes);
      }
      if (selectedTypes.isNotEmpty) {
        query = query.where('type', whereIn: selectedTypes);
      }

      // Start after the last document and limit
      QuerySnapshot snapshot =
          await query.startAfterDocument(_lastDocument!).limit(_pageSize).get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        // Convert new docs to RentalProperty and add to existing list
        List<RentalProperty> newPosts = snapshot.docs.map((doc) {
          return RentalProperty.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        rentals.addAll(newPosts);
      }

      // Check if there are more posts
      hasMorePosts.value = snapshot.docs.length == _pageSize;
      isLoading.value = false;
    } catch (e) {
      log('Error fetching more posts: $e');
      isLoading.value = false;
      hasMorePosts.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await loadInitialPosts();
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
    loadInitialPosts(); // Reload posts after clearing filters
  }
}
