import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/widgets/my_ios_button.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  List<File?> _images = [];
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
  final _propertyTypeController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactNumberController = TextEditingController();

  final List<String> _places = [
    'Kochi',
    'Ernakulam',
    'Aluva',
    'Vytilla',
    'Kakkanad',
  ];
  final List<String> _propertyTypes = ['Apartment', 'House', 'PG'];
  final List<String> _types = ['Rent', 'Lease', 'Sell'];

  late User _currentUser;
  RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _placeController.text = _places.first;
    _propertyTypeController.text = _propertyTypes.first;
    _typeController.text = _types.first;
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (_images.length < 10) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      } else {
        Get.snackbar(
          'Limit Exceeded',
          'You can only add up to 10 images.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _addPost() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;

      final createdAt = Timestamp.now();

      final rentalProperty = RentalProperty(
        id: '',
        imageUrls: [],
        name: _nameController.text,
        description: _descriptionController.text,
        place: _placeController.text,
        propertyType: _propertyTypeController.text,
        type: _typeController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        contactNumber: _contactNumberController.text,
        userId: _currentUser.uid,
        createdAt: createdAt,
        isAvailable: true,
      );

      try {
        List<String> imageUrls = [];
        for (File? image in _images) {
          final imageUrl = await _uploadImage(image!);
          imageUrls.add(imageUrl);
        }

        rentalProperty.imageUrls = imageUrls;

        await FirebaseFirestore.instance
            .collection('rentalProperties')
            .add(rentalProperty.toMap());

        Get.snackbar(
          'Post Added Successfully',
          '',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Get.offAll(() => const AddPostPage());
        Navigator.pop(context);
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.error),
        );
      } finally {
        _isLoading.value = false;
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('rental_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    _propertyTypeController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmationDialog() async {
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Post'),
        content: const Text('Do you want to add this post?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await _addPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const IosButton(),
        title: const Text('Add Rental Property'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: List.generate(_images.length, (index) {
                      return Expanded(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Image.file(
                                  _images[index]!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey.withOpacity(0.7),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                      ..add(
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickImage(ImageSource.gallery),
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Center(
                                child: Icon(Icons.add_a_photo),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    maxLines: 20,
                    minLines: 1,
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _placeController.text,
                    onChanged: (value) {
                      setState(() {
                        _placeController.text = value!;
                      });
                    },
                    items: _places
                        .map((place) => DropdownMenuItem(
                              value: place,
                              child: Text(place),
                            ))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Place'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a place';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _propertyTypeController.text,
                    onChanged: (value) {
                      setState(() {
                        _propertyTypeController.text = value!;
                      });
                    },
                    items: _propertyTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    decoration:
                        const InputDecoration(labelText: 'Property Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a property type';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _typeController.text,
                    onChanged: (value) {
                      setState(() {
                        _typeController.text = value!;
                      });
                    },
                    items: _types
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _contactNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    child: const Text('Add Post'),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => _isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox()),
        ],
      ),
    );
  }
}
