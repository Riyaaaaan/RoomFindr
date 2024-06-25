import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_finder/controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: profileController
                            .userProfileImage.value.isNotEmpty
                        ? NetworkImage(profileController.userProfileImage.value)
                        : null,
                    child: profileController.userProfileImage.value.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        profileController.updateProfileImage();
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey[400],
                        child: const Icon(Icons.edit,
                            size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                  'Name: ${profileController.userName.value.isNotEmpty ? profileController.userName.value : 'Not set'}'),
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: Text(
                  'Email: ${profileController.userEmail.value.isNotEmpty ? profileController.userEmail.value : 'Not set'}'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(
                'Phone Number: ${profileController.userPhoneNumber.value.isNotEmpty ? profileController.userPhoneNumber.value : 'Add phone number'}',
              ),
              trailing: profileController.userPhoneNumber.value.isEmpty
                  ? IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditPhoneNumberDialog(context, profileController);
                      },
                    )
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                profileController.signOut();
              },
            ),
          ],
        );
      }),
    );
  }

  void _showEditPhoneNumberDialog(
      BuildContext context, ProfileController profileController) {
    final TextEditingController phoneNumberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Phone Number'),
          content: TextField(
            controller: phoneNumberController,
            decoration: const InputDecoration(hintText: 'Enter phone number'),
            keyboardType: TextInputType.phone,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final newPhoneNumber = phoneNumberController.text.trim();
                if (newPhoneNumber.isNotEmpty) {
                  profileController.updatePhoneNumber(newPhoneNumber);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
