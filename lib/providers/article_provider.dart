import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/models/article.dart';
import '../data/services/api_service.dart';
import '../data/services/storage_service.dart';

/// Service Providers
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Service Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Articles Provider (fetch from API)
final articlesProvider = FutureProvider.autoDispose.family<List<Article>, int>((
  ref,
  page,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getArticles(page: page);
});

final articleDetailProvider = FutureProvider.autoDispose.family<Article, int>((
  ref,
  articleId,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getArticleById(articleId);
});

/// Bookmarks Provider (load from local storage)
final bookmarksProvider = FutureProvider<List<Article>>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  return storageService.getBookmarks();
});

/// Bookmark Toggle Provider (save/remove bookmark)
final bookmarkToggleProvider = Provider<BookmarkToggle>((ref) {
  return BookmarkToggle(ref);
});

class BookmarkToggle {
  final Ref ref;

  BookmarkToggle(this.ref);

  Future<void> toggle(Article article) async {
    final storageService = ref.read(storageServiceProvider);

    if (article.isBookmarked) {
      await storageService.removeBookmark(article.id);
      article.isBookmarked = false;
    } else {
      await storageService.saveBookmark(article);
      article.isBookmarked = true;
    }

    // Refresh bookmarks list
    ref.invalidate(bookmarksProvider);
  }
}

class BookmarkedArticlesNotifier extends StateNotifier<Set<int>> {
  final StorageService _storageService;

  BookmarkedArticlesNotifier(this._storageService) : super({}) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _storageService.getBookmarks();
    state = bookmarks.map((a) => a.id).toSet();
  }

  Future<void> toggle(Article article) async {
    if (state.contains(article.id)) {
      // Remove bookmark
      await _storageService.removeBookmark(article.id);
      state = {...state}..remove(article.id);
    } else {
      // Add bookmark
      await _storageService.saveBookmark(article);
      state = {...state, article.id};
    }
  }

  bool isBookmarked(int articleId) => state.contains(articleId);
}

final bookmarkedArticlesProvider = 
    StateNotifierProvider<BookmarkedArticlesNotifier, Set<int>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return BookmarkedArticlesNotifier(storageService);
});