import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:room_finder/models/post_model.dart';

class HomeController extends GetxController {
  var rentals = <RentalProperty>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

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
}
