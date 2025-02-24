class Waste {
  final String? id; // Nullable for MongoDB _id compatibility
  final String type; // Non-nullable
  final double quantity; // Non-nullable
  final double price; // Non-nullable
  final String location; // Non-nullable
  final String uploadedBy; // Non-nullable
  final String? image; // Nullable since images are optional
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
      type: json['type'] as String? ?? 'Unknown', // Fallback if null
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0, // Fallback if null
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Fallback if null
      location: json['location'] as String? ?? 'Unknown', // Fallback if null
      uploadedBy: json['uploadedBy'] as String? ?? 'Anonymous', // Fallback if null
      image: json['image'] as String?, // Allow null
      sold: json['sold'] as bool? ?? false, // Defaults to false if null
      purchaseRequests: (json['purchaseRequests'] as List<dynamic>? ?? [])
          .map((request) => PurchaseRequest.fromJson(request as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'quantity': quantity,
      'price': price,
      'location': location,
      'uploadedBy': uploadedBy,
      'image': image,
    };
  }
}

class PurchaseRequest {
  final String? id; // Nullable for MongoDB _id compatibility
  final String? userId; // Nullable, since backend allows it
  final String status; // Non-nullable

  PurchaseRequest({
    this.id, // Optional, can be null
    this.userId, // Optional, can be null
    required this.status, // Required, non-nullable
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    print('Parsing purchase request: $json'); // Debug
    return PurchaseRequest(
      id: json['_id'] as String?, // Allow null for id
      userId: json['userId'] as String? ?? 'Anonymous', // Fallback if null
      status: json['status'] as String? ?? 'pending', // Default to 'pending' if null
    );
  }
}