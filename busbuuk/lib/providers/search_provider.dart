// holds search query + results state for Home / Search Results screens
import 'package:flutter/foundation.dart';
import '../models/bus_model.dart';
import '../services/firestore_service.dart';

class SearchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String? _from;
  String? _to;
  DateTime? _travelDate;
  List<BusModel> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  // just keeping the last few searches in memory for the "recent searches" bit on Home
  final List<String> _recentSearches = [];

  String? get from => _from;
  String? get to => _to;
  DateTime? get travelDate => _travelDate;
  List<BusModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get recentSearches => _recentSearches;

  Future<void> search({
    required String from,
    required String to,
    DateTime? travelDate,
  }) async {
    _from = from;
    _to = to;
    _travelDate = travelDate;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _results = await _firestoreService.searchBuses(from: from, to: to);
      _addRecentSearch('$from → $to');
    } catch (e) {
      _errorMessage = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addRecentSearch(String query) {
    _recentSearches.remove(query); // avoid dupes, bump it to the top instead
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }
  }

  void clearResults() {
    _results = [];
    _errorMessage = null;
    notifyListeners();
  }
}
