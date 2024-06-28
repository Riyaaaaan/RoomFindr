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
        .orderBy('createdAt', descending: true) // Order by createdAt descending
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

  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rentalProperties')
          .doc(postId)
          .delete();
      // Remove the deleted post from the local list
      rentals.removeWhere((post) => post.id == postId);
      Get.snackbar(
        'Success',
        'Post deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to delete post: $e';
      Get.snackbar(
        'Error',
        'Failed to delete post',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updatePostAvailability(RentalProperty rental) async {
    try {
      await FirebaseFirestore.instance
          .collection('rentalProperties')
          .doc(rental.id)
          .update({'isAvailable': rental.isAvailable});
    } catch (e) {
      error.value = 'Failed to update availability: $e';
      Get.snackbar(
        'Error',
        'Failed to update availability',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
