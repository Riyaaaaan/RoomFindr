import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:room_finder/models/post_model.dart';

class LikedController extends GetxController {
  var likedRentals = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLikedRentals();
  }

  void fetchLikedRentals() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Liked')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        likedRentals.value = snapshot.docs.map((doc) => doc.id).toList();
      });
    }
  }

  Future<void> toggleLike(RentalProperty rental) async {
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
        await userLikesRef.set(
            {'rentalId': rentalId, 'timestamp': FieldValue.serverTimestamp()});
        likedRentals.add(rentalId);
      }
    }
  }
}
