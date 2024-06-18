import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:room_finder/models/post_model.dart';

class HomeController extends GetxController {
  var rentals = <RentalProperty>[].obs;
  var likedRentals = <String>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    fetchLikedRentals();
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

  void fetchLikedRentals() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Liked')
          .snapshots()
          .listen((snapshot) {
        likedRentals.value = snapshot.docs.map((doc) => doc.id).toList();
      });
    }
  }

  void toggleLike(RentalProperty rental) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final rentalId = rental.id;
      final userLikesRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Liked')
          .doc(rentalId);

      if (likedRentals.contains(rentalId)) {
        await userLikesRef.delete();
        likedRentals.remove(rentalId);
      } else {
        await userLikesRef.set({'rentalId': rentalId});
        likedRentals.add(rentalId);
      }
    }
  }
}
