import 'package:flutter/foundation.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/services/google_books_api_service.dart';

enum SearchStatus { idle, loading, success, empty, error }

class BookSearchController extends ChangeNotifier {
  BookSearchController({GoogleBooksApiService? apiService})
      : _apiService = apiService ?? GoogleBooksApiService();

  final GoogleBooksApiService _apiService;

  SearchStatus _status = SearchStatus.idle;
  List<Book> _books = [];
  String? _errorMessage;
  String _lastQuery = '';

  SearchStatus get status => _status;
  List<Book> get books => _books;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;
  bool get isLoading => _status == SearchStatus.loading;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;

    if (trimmed.isEmpty) {
      _reset();
      return;
    }

    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.searchBooks(trimmed);
      _books = results;

      if (results.isEmpty) {
        _status = SearchStatus.empty;
        _errorMessage = '검색 결과가 없습니다.';
      } else {
        _status = SearchStatus.success;
      }
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = '검색 중 오류가 발생했습니다. 다시 시도해주세요.';
      if (kDebugMode) {
        print('BookSearchController error: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  void clear() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _status = SearchStatus.idle;
    _books = [];
    _errorMessage = null;
    _lastQuery = '';
  }
}

