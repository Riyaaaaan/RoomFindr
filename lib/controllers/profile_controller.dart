import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_finder/services/auth/auth_page.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhoneNumber = ''.obs;
  var userProfileImage = ''.obs;
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
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
        isLoading.value = true;
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
        }
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
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
            _showOTPDialog(verificationId, phoneNumber);
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

  void _showOTPDialog(String verificationId, String phoneNumber) {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: Get.overlayContext!,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter OTP for $phoneNumber'),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: 'Enter OTP',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Verify'),
              onPressed: () async {
                try {
                  final String otp = otpController.text.trim();
                  if (otp.length != 6) {
                    Get.snackbar('Error', 'Invalid OTP');
                    return;
                  }
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId, smsCode: otp);
                  await _auth.currentUser!.updatePhoneNumber(credential);

                  // Update Firestore after successful verification
                  await _firestore
                      .collection('Users')
                      .doc(_auth.currentUser!.uid)
                      .set({'phoneNumber': phoneNumber},
                          SetOptions(merge: true));

                  userPhoneNumber.value = phoneNumber;
                  Get.back();
                  Get.snackbar('Success', 'Phone number verified and updated');
                } catch (e) {
                  Get.snackbar('Error', 'Failed to verify OTP: $e');
                  log(e.toString());
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    clearUserData();
    Get.offAll(() => const AuthPage());
  }

  void clearUserData() {
    userName.value = '';
    userEmail.value = '';
    userPhoneNumber.value = '';
    userProfileImage.value = '';
  }
}
