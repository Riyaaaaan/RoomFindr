import 'package:cloud_firestore/cloud_firestore.dart';

class RentalProperty {
  String id; // Firestore document ID
  List<String> imageUrls;
  String name;
  String description;
  String place;
  String propertyType;
  String type;
  double price;
  String contactNumber;
  String userId; // User ID who posted the rental
  Timestamp createdAt; // Timestamp when the rental was created
  bool isAvailable; // Availability status

  RentalProperty({
    required this.id,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.place,
    required this.propertyType,
    required this.type,
    required this.price,
    required this.contactNumber,
    required this.userId,
    required this.createdAt,
    this.isAvailable = true, // Default to true when posting
  });

  // Convert RentalProperty to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'place': place,
      'propertyType': propertyType,
      'type': type,
      'price': price,
      'contactNumber': contactNumber,
      'userId': userId,
      'createdAt': createdAt,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
    };
  }

  // Create RentalProperty from a map
  factory RentalProperty.fromMap(Map<String, dynamic> map, String id) {
    return RentalProperty(
      id: id,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      place: map['place'] ?? '',
      propertyType: map['propertyType'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      contactNumber: map['contactNumber'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
