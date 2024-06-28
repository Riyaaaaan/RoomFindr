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
    fetchPosts();
  }

  void fetchPosts() {
    FirebaseFirestore.instance
        .collection('rentalProperties')
        .snapshots()
        .listen((snapshot) {
      rentals.value = snapshot.docs.map((doc) {
        return RentalProperty.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading.value = false;
    }).onError((err) {
      isLoading.value = false;
    });
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void toggleLike(RentalProperty rental) async {
    await likedController.toggleLike(rental);
  }

  void togglePlace(String place, bool selected) {
    if (selected) {
      selectedPlaces.add(place);
    } else {
      selectedPlaces.remove(place);
    }
  }

  void togglePropertyType(String type, bool selected) {
    if (selected) {
      selectedPropertyTypes.add(type);
    } else {
      selectedPropertyTypes.remove(type);
    }
  }

  void toggleType(String type, bool selected) {
    if (selected) {
      selectedTypes.add(type);
    } else {
      selectedTypes.remove(type);
    }
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
