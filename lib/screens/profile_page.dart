import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:room_finder/controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    final GetStorage _box = GetStorage();

    RxBool isSwitched = RxBool(_box.read('isDarkMode') ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: GetX<ProfileController>(
        init: profileController,
        builder: (controller) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage:
                          controller.userProfileImage.value.isNotEmpty
                              ? NetworkImage(controller.userProfileImage.value)
                              : null,
                      child: controller.isAvatarLoading.value
                          ? const CircularProgressIndicator()
                          : (controller.userProfileImage.value.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          controller.updateProfileImage();
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
                    'Name: ${controller.userName.value.isNotEmpty ? controller.userName.value : 'Not set'}'),
              ),
              ListTile(
                leading: const Icon(Icons.mail),
                title: Text(
                    'Email: ${controller.userEmail.value.isNotEmpty ? controller.userEmail.value : 'Not set'}'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(
                  'Phone Number: ${controller.userPhoneNumber.value.isNotEmpty ? controller.userPhoneNumber.value : 'Add phone number'}',
                ),
                trailing: controller.userPhoneNumber.value.isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditPhoneNumberBottomSheet(controller);
                        },
                      )
                    : null,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Obx(() => Switch(
                      value: isSwitched.value,
                      onChanged: (value) {
                        isSwitched.value = value;
                        Get.changeTheme(
                          value ? ThemeData.dark() : ThemeData.light(),
                        );
                        _box.write('isDarkMode', value);
                      },
                    )),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
                  controller.signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditPhoneNumberBottomSheet(ProfileController profileController) {
    final TextEditingController phoneNumberController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Phone Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                hintStyle: TextStyle(
                  color: Get.isDarkMode ? Colors.white70 : Colors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Get.isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              style: TextStyle(
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Get.isDarkMode ? Colors.blue : Colors.blue,
                  ),
                  child: const Text('Cancel'),
                  onPressed: () {
                    Get.back();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Get.isDarkMode ? Colors.blue : Colors.blue,
                  ),
                  child: const Text('Save'),
                  onPressed: () {
                    final newPhoneNumber = phoneNumberController.text.trim();
                    if (newPhoneNumber.isNotEmpty) {
                      profileController.updatePhoneNumber(newPhoneNumber);
                      Get.back();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}
