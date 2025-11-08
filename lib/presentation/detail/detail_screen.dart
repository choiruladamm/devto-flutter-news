import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/providers/article_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends ConsumerWidget {
  final int articleId;

  const DetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));

    return Scaffold(
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(articleDetailProvider(articleId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        data: (article) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image
                    article.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: article.coverImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                              ),
                            ),
                          )
                        : Container(color: Colors.grey[300]),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final bookmarkedArticles = ref.watch(
                      bookmarkedArticlesProvider,
                    );
                    final isBookmarked = bookmarkedArticles.contains(
                      article.id,
                    );

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ref
                              .read(bookmarkedArticlesProvider.notifier)
                              .toggle(article);
                          ref.invalidate(bookmarksProvider);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // tags
                    if (article.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: article.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    // Author Info
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            article.authorImage,
                          ),
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              Text(
                                '${article.readingTime} min read • ${_formatDate(article.publishedAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Article Content (HTML)
                    if (article.bodyHtml != null)
                      Html(
                        data: article.bodyHtml!,
                        extensions: [
                          TagExtension(
                            tagsToExtend: {"img"},
                            builder: (extensionContext) {
                              final src = extensionContext.attributes['src'];
                              if (src == null) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: src,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ],
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.6),
                          ),
                          "p": Style(margin: Margins.only(bottom: 16)),
                          "h1": Style(
                            fontSize: FontSize(24),
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(top: 24, bottom: 16),
                          ),
                          "h2": Style(
                            fontSize: FontSize(20),
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(top: 20, bottom: 12),
                          ),
                          "pre": Style(
                            backgroundColor: Colors.grey[100],
                            padding: HtmlPaddings.all(12),
                          ),
                          "code": Style(
                            backgroundColor: Colors.grey[100],
                            padding: HtmlPaddings.symmetric(horizontal: 4),
                          ),
                        },
                        onLinkTap: (url, _, __) {
                          if (url != null) _launchURL(url);
                        },
                      )
                    else
                      Text(
                        article.description,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),

                    const SizedBox(height: 32),

                    // Read on Dev.to Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _launchURL(article.url),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Read on Dev.to'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
