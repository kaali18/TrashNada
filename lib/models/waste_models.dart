class Waste {
  final String id;
  final String type;
  final double quantity;
  final double price;
  final String location;
  final String uploadedBy;
  final DateTime createdAt;
  final bool sold;

  Waste({
    required this.id,
    required this.type,
    required this.quantity,
    required this.price,
    required this.location,
    required this.uploadedBy,
    required this.createdAt,
    this.sold = false,
  });

  factory Waste.fromJson(Map<String, dynamic> json) {
    return Waste(
      id: json['_id'],
      type: json['type'],
      quantity: json['quantity'].toDouble(),
      price: json['price'].toDouble(),
      location: json['location'],
      uploadedBy: json['uploadedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      sold: json['sold'] ?? false,
    );
  }
}