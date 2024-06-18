import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:room_finder/models/post_model.dart';

class PostController extends GetxController {
  var rentals = <RentalProperty>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void fetchPosts() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      error.value = 'User not logged in';
      isLoading.value = false;
      return;
    }

    FirebaseFirestore.instance
        .collection('rentalProperties')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      rentals.value = snapshot.docs.map((doc) {
        return RentalProperty.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading.value = false;
    }).onError((err) {
      error.value = err.toString();
      isLoading.value = false;
    });
  }
}
