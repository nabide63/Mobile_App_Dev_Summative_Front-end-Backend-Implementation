// bus trip/route data model
class BusModel {
  final String id;
  final String operatorName;
  final String from;
  final String to;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String busType; // e.g "Standard", "VIP"

  BusModel({
    required this.id,
    required this.operatorName,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.busType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operatorName': operatorName,
      'from': from,
      'to': to,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'price': price,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'busType': busType,
    };
  }

  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'] as String,
      operatorName: map['operatorName'] as String,
      from: map['from'] as String,
      to: map['to'] as String,
      departureTime: DateTime.parse(map['departureTime'] as String),
      arrivalTime: DateTime.parse(map['arrivalTime'] as String),
      price: (map['price'] as num).toDouble(),
      totalSeats: map['totalSeats'] as int,
      availableSeats: map['availableSeats'] as int,
      busType: map['busType'] as String,
    );
  }
}
