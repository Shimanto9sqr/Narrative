import 'package:flutter/material.dart';
import 'package:narrative/utils/category_card.dart';
import 'package:provider/provider.dart';
import 'package:narrative/viewmodels/auth_viewmodel.dart';
import 'package:narrative/viewmodels/news_viewmodel.dart';
import 'package:narrative/models/user_preference_model.dart';
import 'package:narrative/views/news_feed_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final Set<String> _selectedCategories = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  Future<void> _loadExistingPreferences() async {
    final authViewModel = context.read<AuthViewModel>();
    final newsFeedViewModel = context.read<NewsFeedViewModel>();

    if (authViewModel.userId != null) {
      await newsFeedViewModel.loadUserPreferences(authViewModel.userId!);

      if (newsFeedViewModel.userPreferences != null) {
        setState(() {
          _selectedCategories.addAll(
            newsFeedViewModel.userPreferences!.selectedCategories,
          );
        });
      }
    }

    setState(() {
      _isInitialized = true;
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _savePreferences() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final newsFeedViewModel = context.read<NewsFeedViewModel>();

    if (authViewModel.userId != null) {
      await newsFeedViewModel.saveUserPreferences(
        userId: authViewModel.userId!,
        selectedCategories: _selectedCategories.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NewsFeedScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Interests'),
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authViewModel.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NewsFeedViewModel>(
        builder: (context, newsFeedViewModel, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Choose categories you\'re interested in',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select at least one category to personalize your news feed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: NewsCategories.all.length,
                  itemBuilder: (context, index) {
                    final category = NewsCategories.all[index];
                    final displayName = NewsCategories.displayNames[category]!;
                    final isSelected = _selectedCategories.contains(category);

                    return CategoryCard(
                      category: category,
                      displayName: displayName,
                      isSelected: isSelected,
                      onTap: () => _toggleCategory(category),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: newsFeedViewModel.isLoading ? null : _savePreferences,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: newsFeedViewModel.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Save & Continue (${_selectedCategories.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
