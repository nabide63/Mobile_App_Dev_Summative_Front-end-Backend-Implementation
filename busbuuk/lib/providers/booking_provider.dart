// holds seat selection, passenger details and payment state for the booking flow
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';
import '../models/seat_model.dart';
import '../models/passenger_model.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  BusModel? _selectedBus;
  List<SeatModel> _seats = [];
  List<PassengerModel> _passengers = [];
  String _paymentMethod = 'card';
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> _myBookings = [];

  BusModel? get selectedBus => _selectedBus;
  List<SeatModel> get seats => _seats;
  List<String> get selectedSeatNumbers =>
      _seats.where((s) => s.isSelected).map((s) => s.seatNumber).toList();
  List<PassengerModel> get passengers => _passengers;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BookingModel> get myBookings => _myBookings;

  double get totalAmount =>
      (_selectedBus?.price ?? 0) * selectedSeatNumbers.length;

  // called when the user taps into a bus from search results
  Future<void> selectBus(BusModel bus) async {
    _selectedBus = bus;
    _isLoading = true;
    notifyListeners();

    try {
      _seats = await _firestoreService.getSeatsForBus(bus.id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _seats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSeat(String seatNumber) {
    final index = _seats.indexWhere((s) => s.seatNumber == seatNumber);
    if (index == -1) return;

    final seat = _seats[index];
    if (seat.isBooked) return; // can't select a seat that's already taken

    seat.isSelected = !seat.isSelected;
    notifyListeners();
  }

  void setPassengers(List<PassengerModel> passengers) {
    _passengers = passengers;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  // creates the booking doc once payment goes through
  Future<BookingModel?> confirmBooking({required String userId}) async {
    if (_selectedBus == null || selectedSeatNumbers.isEmpty) {
      _errorMessage = 'pick a bus and at least one seat first';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final bookingId = FirebaseFirestore.instance
          .collection('bookings')
          .doc()
          .id;

      final booking = BookingModel(
        id: bookingId,
        userId: userId,
        busId: _selectedBus!.id,
        seatNumbers: selectedSeatNumbers,
        passengers: _passengers,
        totalAmount: totalAmount,
        bookingDate: DateTime.now(),
        status: 'confirmed',
      );

      await _firestoreService.createBooking(booking);
      _errorMessage = null;
      return booking;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _myBookings = await _firestoreService.getUserBookings(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // wipe the booking flow state once a booking is done (or abandoned)
  void resetBookingFlow() {
    _selectedBus = null;
    _seats = [];
    _passengers = [];
    _paymentMethod = 'card';
    _errorMessage = null;
    notifyListeners();
  }
}
