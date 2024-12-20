import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_finder/services/auth/auth_page.dart';
import 'package:room_finder/controllers/post_controller.dart';
import 'package:room_finder/controllers/liked_controller.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userProfileImage = ''.obs;
  var isLoading = false.obs;
  var isAvatarLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        userName.value = userDoc['name'] ?? '';
        userEmail.value = userDoc['email'] ?? '';
        userProfileImage.value = userDoc['profileImage'] ?? '';
      }
    } catch (e) {
      log('Error fetching user data: $e');
    }
  }

  Future<void> updateProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        isAvatarLoading.value = true;
        final File file = File(pickedFile.path);
        final User? user = _auth.currentUser;
        if (user != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profileImages')
              .child('${user.uid}.jpg');
          await storageRef.putFile(file);
          final imageUrl = await storageRef.getDownloadURL();
          await _firestore
              .collection('Users')
              .doc(user.uid)
              .set({'profileImage': imageUrl}, SetOptions(merge: true));
          userProfileImage.value = imageUrl;
          Get.snackbar('Success', 'Profile image updated');

          // Fetch the updated user profile
          await fetchUserProfile();
        }
        isAvatarLoading.value = false;
      }
    } catch (e) {
      isAvatarLoading.value = false;
      Get.snackbar('Error', 'Failed to update profile image');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    clearUserData();
    clearMyPosts();
    clearLikedPosts();
    Get.offAll(() => const AuthPage());
  }

  void clearUserData() {
    userName.value = '';
    userEmail.value = '';
    userProfileImage.value = '';
  }

  void clearMyPosts() {
    if (!Get.isRegistered<PostController>()) {
      Get.lazyPut(() => PostController());
    }
    Get.find<PostController>().clearPosts();
  }

  void clearLikedPosts() {
    if (!Get.isRegistered<LikedController>()) {
      Get.lazyPut(() => LikedController());
    }
    Get.find<LikedController>().clearLikedRentals();
  }
}
