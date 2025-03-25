import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// ✅ MAIN APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FakeStore API Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/products': (context) => const ProductsScreen(),
      },
    );
  }
}
