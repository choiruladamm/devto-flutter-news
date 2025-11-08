import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/article_provider.dart';
import '../widgets/article_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider(1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev.to Articles'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push('/bookmarks'),
          ),
        ],
      ),
      body: articlesAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const Center(child: Text('No articles found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(articlesProvider(1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(article: article);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(articlesProvider(1)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
