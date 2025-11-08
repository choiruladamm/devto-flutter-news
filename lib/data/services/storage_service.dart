import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class StorageService {
  static const String _bookmarksKey = 'bookmarks';

  // Get all bookmarks
  Future<List<Article>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getString(_bookmarksKey);

    if (bookmarksJson == null) return [];

    final List<dynamic> decoded = json.decode(bookmarksJson);
    return decoded.map((json) => Article.fromJson(json)).toList();
  }

  // Save bookmark
  Future<void> saveBookmark(Article article) async {
    final bookmarks = await getBookmarks();

    if (!bookmarks.any((a) => a.id == article.id)) {
      article.isBookmarked = true;
      bookmarks.add(article);
      await _saveBookmarks(bookmarks);
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(int articleId) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((a) => a.id == articleId);
    await _saveBookmarks(bookmarks);
  }

  // Check if article is bookmarked
  Future<bool> isBookmarked(int articleId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((a) => a.id == articleId);
  }

  // Private: Save bookmarks list
  Future<void> _saveBookmarks(List<Article> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = json.encode(
      bookmarks.map((article) => article.toJson()).toList(),
    );
    await prefs.setString(_bookmarksKey, bookmarksJson);
  }
}
