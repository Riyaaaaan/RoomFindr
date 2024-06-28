import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import 'package:room_finder/controllers/profile_controller.dart';
import 'package:room_finder/screens/add_post.dart';

class AddPost extends StatelessWidget {
  const AddPost({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    return Scaffold(
      body: Center(
        child: OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration:
              const Duration(milliseconds: 500), // Increased duration
          openBuilder: (BuildContext context, VoidCallback _) {
            return const AddPostPage();
          },
          closedElevation: 6.0,
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(56 / 2)),
          ),
          closedColor: Theme.of(context).colorScheme.secondary,
          closedBuilder: (BuildContext context, VoidCallback openContainer) {
            return FloatingActionButton.large(
              onPressed: () {
                if (profileController.userPhoneNumber.value.isNotEmpty &&
                    profileController.userProfileImage.value.isNotEmpty) {
                  openContainer();
                } else {
                  Get.snackbar(
                    'Profile Incomplete',
                    'Please verify your phone number and upload a profile image before posting.',
                    snackPosition: SnackPosition.BOTTOM,
                    icon: const Icon(Icons.error),
                  );
                }
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
