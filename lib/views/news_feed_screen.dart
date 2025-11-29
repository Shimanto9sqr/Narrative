
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:narrative/viewmodels/auth_viewmodel.dart';
import 'package:narrative/viewmodels/news_viewmodel.dart';
import 'package:narrative/views/preferences_screen.dart';
import 'package:narrative/utils/article_card.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNews();
    });
  }

  Future<void> _loadNews() async {
    final authViewModel = context.read<AuthViewModel>();
    final newsFeedViewModel = context.read<NewsFeedViewModel>();

    if (authViewModel.userId != null) {
      await newsFeedViewModel.fetchPersonalizedNews(authViewModel.userId!);
    }
  }

  Future<void> _refreshNews() async {
    final authViewModel = context.read<AuthViewModel>();
    final newsFeedViewModel = context.read<NewsFeedViewModel>();

    if (authViewModel.userId != null) {
      await newsFeedViewModel.refreshNews(authViewModel.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your News Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreferencesScreen()),
              );
            },
          ),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'logout') {
                    context.read<NewsFeedViewModel>().reset();
                    await authViewModel.signOut();
                    authViewModel.clearMessages();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NewsFeedViewModel>(
        builder: (context, newsFeedViewModel, child) {
          if (newsFeedViewModel.isLoading && newsFeedViewModel.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (newsFeedViewModel.errorMessage != null &&
              newsFeedViewModel.articles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      newsFeedViewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadNews,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (newsFeedViewModel.articles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.newspaper,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No articles available',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your preferences or try again later',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PreferencesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Update Preferences'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshNews,
            child: ListView.builder(
              itemCount: newsFeedViewModel.articles.length,
              itemBuilder: (context, index) {
                final article = newsFeedViewModel.articles[index];
                return ArticleCard(article: article);
              },
            ),
          );
        },
      ),
    );
  }
}