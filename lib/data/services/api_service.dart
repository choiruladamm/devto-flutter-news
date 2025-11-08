import 'package:dio/dio.dart';
import '../models/article.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  /// Fetch articles
  Future<List<Article>> getArticles({int page = 1, String? tag}) async {
    try {
      final response = await _dio.get(
        ApiConstants.articles,
        queryParameters: {
          'page': page,
          'per_page': ApiConstants.perPage,
          if (tag != null) 'tag': tag,
        },
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Article.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch articles: ${e.message}');
    }
  }

  /// Fetch a single article by its ID
  Future<Article> getArticleById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.articles}/$id');
      return Article.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch article detail: ${e.message}');
    }
  }
}
