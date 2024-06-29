import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_finder/services/auth/auth_page.dart';
import 'package:room_finder/controllers/post_controller.dart';
import 'package:room_finder/controllers/liked_controller.dart';
import 'package:pinput/pinput.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhoneNumber = ''.obs;
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
        userPhoneNumber.value = userDoc['phoneNumber'] ?? '';
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

  Future<void> updatePhoneNumber(String phoneNumber) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        if (!phoneNumber.startsWith('+')) {
          phoneNumber = '+91$phoneNumber';
        }

        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              await user.updatePhoneNumber(credential);
              userPhoneNumber.value = phoneNumber;
              await _firestore
                  .collection('Users')
                  .doc(user.uid)
                  .set({'phoneNumber': phoneNumber}, SetOptions(merge: true));
              Get.snackbar('Success', 'Phone number updated');
            } catch (e) {
              Get.snackbar('Error', 'Failed to update phone number: $e');
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            Get.snackbar('Error', 'Verification failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            _showOTPBottomSheet(verificationId, phoneNumber);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            Get.snackbar(
                'Error', 'OTP code retrieval timeout. Please try again.');
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update phone number: $e');
    }
  }

  void _showOTPBottomSheet(String verificationId, String phoneNumber) {
    final pinController = TextEditingController();
    final focusNode = FocusNode();
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter OTP for $phoneNumber',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Pinput(
                controller: pinController,
                focusNode: focusNode,
                length: 6,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
                  ),
                ),
                validator: (value) {
                  return value?.length == 6
                      ? null
                      : 'OTP must be 6 digits long';
                },
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                closeKeyboardWhenCompleted: true,
                hapticFeedbackType: HapticFeedbackType.vibrate,
                showCursor: true,
                onCompleted: (pin) => log(pin),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Get.isDarkMode ? Colors.blueGrey : Colors.blue,
                ),
                child: const Text('Verify'),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final String otp = pinController.text.trim();
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: otp,
                      );
                      await _auth.currentUser!.updatePhoneNumber(credential);

                      await _firestore
                          .collection('Users')
                          .doc(_auth.currentUser!.uid)
                          .set(
                        {'phoneNumber': phoneNumber},
                        SetOptions(merge: true),
                      );

                      userPhoneNumber.value = phoneNumber;
                      Get.back();
                      Get.snackbar(
                          'Success', 'Phone number verified and updated');
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to verify OTP: $e');
                      log(e.toString());
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
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
    userPhoneNumber.value = '';
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
