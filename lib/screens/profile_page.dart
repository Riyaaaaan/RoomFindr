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
}
