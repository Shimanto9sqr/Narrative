import 'package:flutter/foundation.dart';
import 'package:narrative/models/article_model.dart';
import 'package:narrative/models/user_preference_model.dart';
import 'package:narrative/services/news_api_service.dart';
import 'package:narrative/services/local_db_service.dart';


class NewsFeedViewModel extends ChangeNotifier {
  final NewsApiService _newsApiService;
  final LocalDbService _localDbService;

  List<Article> _articles = [];
  UserPreferences? _userPreferences;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;

  NewsFeedViewModel({
    required NewsApiService newsApiService,
    required LocalDbService localDbService,
  })  : _newsApiService = newsApiService,
        _localDbService = localDbService;

  List<Article> get articles => _articles;
  UserPreferences? get userPreferences => _userPreferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPreferences => _userPreferences?.selectedCategories.isNotEmpty ?? false;
  DateTime? get lastFetchTime => _lastFetchTime;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }


  Future<void> loadUserPreferences(String userId) async {
    try {
      _userPreferences = await _localDbService.getUserPreferences(userId);
      notifyListeners();
    } catch (e) {
      _setError('Error loading preferences: $e');
    }
  }

  Future<void> saveUserPreferences({
    required String userId,
    required List<String> selectedCategories,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final preferences = UserPreferences(
        userId: userId,
        selectedCategories: selectedCategories,
        lastUpdated: DateTime.now(),
      );

      await _localDbService.saveUserPreferences(preferences);
      _userPreferences = preferences;

      _setLoading(false);

      await fetchPersonalizedNews(userId);
    } catch (e) {
      _setError('Error saving preferences: $e');
      _setLoading(false);
    }
  }

  Future<void> fetchPersonalizedNews(String userId) async {
    _setLoading(true);
    clearError();

    try {
      if (_userPreferences == null) {
        await loadUserPreferences(userId);
      }

      if (_userPreferences == null ||
          _userPreferences!.selectedCategories.isEmpty) {
        _setError('Please select your news preferences first');
        _setLoading(false);
        return;
      }

      final articles = await _newsApiService.fetchPersonalizedFeed(
        categories: _userPreferences!.selectedCategories,
      );

      _articles = articles;
      _lastFetchTime = DateTime.now();

      final updatedPreferences = _userPreferences!.copyWith(
        lastUpdated: DateTime.now(),
      );
      await _localDbService.updateUserPreferences(updatedPreferences);
      _userPreferences = updatedPreferences;

      _setLoading(false);
    } catch (e) {
      _setError('Error fetching news: $e');
      _setLoading(false);
    }
  }

  Future<void> refreshNews(String userId) async {
    await fetchPersonalizedNews(userId);
  }

  bool shouldRefreshNews() {
    if (_lastFetchTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastFetchTime!);

    return difference.inHours >= 12;
  }

  Future<void> fetchNewsByCategory(String category) async {
    _setLoading(true);
    clearError();

    try {
      final articles = await _newsApiService.fetchTopHeadlinesByCategory(
        category: category,
      );
      _articles = articles;
      _lastFetchTime = DateTime.now();
      _setLoading(false);
    } catch (e) {
      _setError('Error fetching news: $e');
      _setLoading(false);
    }
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      _setError('Please enter a search query');
      return;
    }

    _setLoading(true);
    clearError();

    try {
      final articles = await _newsApiService.searchArticles(query: query);
      _articles = articles;
      _lastFetchTime = DateTime.now();
      _setLoading(false);
    } catch (e) {
      _setError('Error searching news: $e');
      _setLoading(false);
    }
  }

  Future<void> updateCategories({
    required String userId,
    required List<String> categories,
  }) async {
    await saveUserPreferences(
      userId: userId,
      selectedCategories: categories,
    );
  }

  void clearArticles() {
    _articles = [];
    notifyListeners();
  }

  void reset() {
    _articles = [];
    _userPreferences = null;
    _errorMessage = null;
    _lastFetchTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}