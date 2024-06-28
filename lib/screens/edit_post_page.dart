import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:room_finder/controllers/post_controller.dart';
import 'package:room_finder/models/post_model.dart';
import 'package:room_finder/widgets/my_ios_button.dart';

class EditPostPage extends StatefulWidget {
  final RentalProperty rental;

  const EditPostPage({super.key, required this.rental});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _contactNumberController;

  String? _selectedPlace;
  String? _selectedPropertyType;
  String? _selectedType;

  final List<String> _places = [
    'Kochi',
    'Ernakulam',
    'Aluva',
    'Vytilla',
    'Kakkanad',
  ];
  final List<String> _propertyTypes = ['Apartment', 'House', 'PG'];
  final List<String> _types = ['Rent', 'Lease', 'Sell'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rental.name);
    _descriptionController =
        TextEditingController(text: widget.rental.description);
    _priceController =
        TextEditingController(text: widget.rental.price.toString());
    _contactNumberController =
        TextEditingController(text: widget.rental.contactNumber);
    _selectedPlace = widget.rental.place;
    _selectedPropertyType = widget.rental.propertyType;
    _selectedType = widget.rental.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        leading: const IosButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator:
                      RequiredValidator(errorText: 'Please enter the name'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: RequiredValidator(
                      errorText: 'Please enter the description'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPlace,
                  items: _places.map((String place) {
                    return DropdownMenuItem<String>(
                      value: place,
                      child: Text(place),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlace = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Place'),
                  validator: (value) =>
                      value == null ? 'Please select a place' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPropertyType,
                  items: _propertyTypes.map((String propertyType) {
                    return DropdownMenuItem<String>(
                      value: propertyType,
                      child: Text(propertyType),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPropertyType = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Property Type'),
                  validator: (value) =>
                      value == null ? 'Please select a property type' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: _types.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Type'),
                  validator: (value) =>
                      value == null ? 'Please select a type' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Please enter the price'),
                    PatternValidator(r'^[0-9]+(\.[0-9]{1,2})?$',
                        errorText: 'Please enter a valid price'),
                  ]),
                ),
                TextFormField(
                  controller: _contactNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: 'Please enter the contact number'),
                    LengthRangeValidator(
                        min: 10,
                        max: 10,
                        errorText:
                            'Please enter a valid 10-digit contact number'),
                  ]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      RentalProperty updatedRental = RentalProperty(
                        id: widget.rental.id,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        place: _selectedPlace!,
                        propertyType: _selectedPropertyType!,
                        type: _selectedType!,
                        price: double.parse(_priceController.text),
                        contactNumber: _contactNumberController.text,
                        imageUrls: widget.rental.imageUrls,
                        isAvailable: widget.rental.isAvailable,
                        userId: widget.rental.userId,
                        createdAt: widget.rental.createdAt,
                      );
                      Get.find<PostController>().editPost(updatedRental);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
