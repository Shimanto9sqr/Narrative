import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:narrative/models/article_model.dart';
import 'package:narrative/utils/constants.dart';

class NewsApiService {
  final String _baseUrl = AppConstants.newsApiBaseUrl;
  final String _apiKey = AppConstants.newsApiKey;

  Future<List<Article>> fetchTopHeadlinesByCategory({
    required String category,
    String country = 'us',
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/top-headlines?country=$country&category=$category&pageSize=$pageSize&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];

        return articlesJson
            .map((json) => Article.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your NewsAPI key.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  Future<List<Article>> fetchPersonalizedFeed({
    required List<String> categories,
    String country = 'us',
    int pageSize = 20,
  }) async {
    if (categories.isEmpty) {
      return [];
    }

    try {
      final List<Future<List<Article>>> futures = categories.map((category) {
        return fetchTopHeadlinesByCategory(
          category: category,
          country: country,
          pageSize: pageSize ~/ categories.length + 5, // Distribute page size
        );
      }).toList();

      final List<List<Article>> results = await Future.wait(futures);

      final Map<String, Article> uniqueArticles = {};
      for (final articleList in results) {
        for (final article in articleList) {
          if (!uniqueArticles.containsKey(article.url)) {
            uniqueArticles[article.url] = article;
          }
        }
      }

      final articles = uniqueArticles.values.toList();
      articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return articles.take(pageSize).toList();
    } catch (e) {
      throw Exception('Error fetching personalized feed: $e');
    }
  }

  Future<List<Article>> searchArticles({
    required String query,
    String sortBy = 'publishedAt',
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/everything?q=$query&sortBy=$sortBy&pageSize=$pageSize&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];

        return articlesJson
            .map((json) => Article.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching articles: $e');
    }
  }

  Future<List<Article>> fetchFromSources({
    required List<String> sources,
    int pageSize = 20,
  }) async {
    try {
      final sourcesString = sources.join(',');
      final url = Uri.parse(
        '$_baseUrl/top-headlines?sources=$sourcesString&pageSize=$pageSize&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];

        return articlesJson
            .map((json) => Article.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching from sources: $e');
    }
  }
}