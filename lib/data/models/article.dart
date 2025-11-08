class Article {
  final int id;
  final String title;
  final String description;
  final String? coverImage;
  final String publishedAt;
  final String url;
  final List<String> tags;
  final String authorName;
  final String authorImage;
  final int readingTime;
  final String? bodyHtml;
  bool isBookmarked;

  Article({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.publishedAt,
    required this.url,
    required this.tags,
    required this.authorName,
    required this.authorImage,
    required this.readingTime,
    this.bodyHtml,
    this.isBookmarked = false,
  });

  /// Parse tag_list from JSON, handle different data types
  static List<String> _parseTags(dynamic tagList) {
    if (tagList == null) return [];

    if (tagList is String) {
      return tagList.split(',').map((tag) => tag.trim()).toList();
    }

    if (tagList is List) {
      return tagList.map((tag) => tag.toString()).toList();
    }

    return [];
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      coverImage: json['cover_image'],
      publishedAt: json['published_at'],
      url: json['url'],
      tags: _parseTags(json['tag_list']),
      authorName: json['user']['name'],
      authorImage: json['user']['profile_image'],
      readingTime: json['reading_time_minutes'] ?? 5,
      bodyHtml: json['body_html'],
    );
  }

  /// Convert Article object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'published_at': publishedAt,
      'url': url,
      'tag_list': tags,
      'user': {'name': authorName, 'profile_image': authorImage},
      'reading_time_minutes': readingTime,
      'body_html': bodyHtml,
      'isBookmarked': isBookmarked,
    };
  }

  /// Create a copy of the Article with optional fields updated
  Article copyWith({bool? isBookmarked}) {
    return Article(
      id: id,
      title: title,
      description: description,
      coverImage: coverImage,
      publishedAt: publishedAt,
      url: url,
      tags: tags,
      authorName: authorName,
      authorImage: authorImage,
      readingTime: readingTime,
      bodyHtml: bodyHtml,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
