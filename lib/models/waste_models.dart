class Waste {
  final String? id; // Nullable (String?) for MongoDB _id compatibility
  final String type; // Non-nullable
  final double quantity; // Non-nullable
  final double price; // Non-nullable
  final String location; // Non-nullable
  final String uploadedBy; // Non-nullable
  final String? image; // Nullable (String?) since images can be optional
  final bool sold; // Non-nullable
  final List<PurchaseRequest> purchaseRequests; // Non-nullable, defaults to empty list

  Waste({
    this.id, // Optional, can be null
    required this.type, // Required, non-nullable
    required this.quantity, // Required, non-nullable
    required this.price, // Required, non-nullable
    required this.location, // Required, non-nullable
    required this.uploadedBy, // Required, non-nullable
    this.image, // Optional, can be null
    this.sold = false, // Non-nullable, defaults to false
    this.purchaseRequests = const [], // Non-nullable, defaults to empty list
  });

  factory Waste.fromJson(Map<String, dynamic> json) {
    print('Parsing waste item: $json'); // Debug
    return Waste(
      id: json['_id'] as String?, // Allow null for id
      type: json['type'] as String, // Expects non-null String
      quantity: (json['quantity'] as num).toDouble(), // Expects non-null num
      price: (json['price'] as num).toDouble(), // Expects non-null num
      location: json['location'] as String, // Expects non-null String
      uploadedBy: json['uploadedBy'] as String, // Expects non-null String
      image: json['image'] as String?, // Allow null
      sold: json['sold'] as bool? ?? false, // Defaults to false if null
      purchaseRequests: (json['purchaseRequests'] as List<dynamic>? ?? [])
          .map((request) => PurchaseRequest.fromJson(request as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type, // Non-nullable
      'quantity': quantity, // Non-nullable
      'price': price, // Non-nullable
      'location': location, // Non-nullable
      'uploadedBy': uploadedBy, // Non-nullable
      'image': image, // Can be null
    };
  }
}

class PurchaseRequest {
  final String? id; // Nullable (String?) for MongoDB _id compatibility
  final String userId; // Non-nullable, corrected to 'userId'
  final String status; // Non-nullable

  PurchaseRequest({
    this.id, // Optional, can be null
    required this.userId, // Required, non-nullable
    required this.status, // Required, non-nullable
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    print('Parsing purchase request: $json'); // Debug
    return PurchaseRequest(
      id: json['_id'] as String?, // Allow null for id
      userId: json['userId'] as String, // Expects non-null String, corrected from 'userld'
      status: (json['status'] as String?) ?? 'pending', // Default to 'pending' if null
    );
  }
}