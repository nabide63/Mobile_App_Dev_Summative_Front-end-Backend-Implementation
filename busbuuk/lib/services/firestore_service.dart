// Firestore reads/writes - users, buses, bookings
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/bus_model.dart';
import '../models/seat_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- users ----

  Future<void> createUserProfile(UserModel user) {
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // ---- buses / search ----

  Future<List<BusModel>> searchBuses({
    required String from,
    required String to,
  }) async {
    final snapshot = await _db
        .collection('buses')
        .where('from', isEqualTo: from)
        .where('to', isEqualTo: to)
        .get();
    return snapshot.docs.map((d) => BusModel.fromMap(d.data())).toList();
  }

  // ---- seats ----

  Future<List<SeatModel>> getSeatsForBus(String busId) async {
    final snapshot = await _db
        .collection('buses')
        .doc(busId)
        .collection('seats')
        .get();
    return snapshot.docs.map((d) => SeatModel.fromMap(d.data())).toList();
  }

  // ---- bookings ----

  Future<void> createBooking(BookingModel booking) {
    return _db.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .get();
    return snapshot.docs.map((d) => BookingModel.fromMap(d.data())).toList();
  }
}
