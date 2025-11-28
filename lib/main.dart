import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:narrative/services/auth_service.dart';
import 'package:narrative/services/news_api_service.dart';
import 'package:narrative/services/local_db_service.dart';
import 'package:narrative/viewmodels/auth_viewmodel.dart';
import 'package:narrative/viewmodels/news_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/news_feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final authService = AuthService();
    final newsApiService = NewsApiService();
    final localDbService = LocalDbService();

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<NewsApiService>.value(value: newsApiService),
        Provider<LocalDbService>.value(value: localDbService),

        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(
            authService: authService,
            localDbService: localDbService,
          ),
        ),
        ChangeNotifierProvider<NewsFeedViewModel>(
          create: (_) => NewsFeedViewModel(
            newsApiService: newsApiService,
            localDbService: localDbService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Personalized News Feed',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoggedIn) {
          return const NewsFeedScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}