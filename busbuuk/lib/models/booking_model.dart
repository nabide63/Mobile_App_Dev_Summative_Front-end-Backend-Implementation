// ticket booking data model
import 'passenger_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String busId;
  final List<String> seatNumbers;
  final List<PassengerModel> passengers;
  final double totalAmount;
  final DateTime bookingDate;
  final String status; // "pending", "confirmed", "cancelled"
  final String? paymentId;

  BookingModel({
    required this.id,
    required this.userId,
    required this.busId,
    required this.seatNumbers,
    required this.passengers,
    required this.totalAmount,
    required this.bookingDate,
    required this.status,
    this.paymentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'busId': busId,
      'seatNumbers': seatNumbers,
      'passengers': passengers.map((p) => p.toMap()).toList(),
      'totalAmount': totalAmount,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
      'paymentId': paymentId,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      busId: map['busId'] as String,
      seatNumbers: List<String>.from(map['seatNumbers'] as List),
      passengers: (map['passengers'] as List)
          .map((p) => PassengerModel.fromMap(p as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      bookingDate: DateTime.parse(map['bookingDate'] as String),
      status: map['status'] as String,
      paymentId: map['paymentId'] as String?,
    );
  }
}
