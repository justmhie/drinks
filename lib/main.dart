import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

// ✅ PRODUCTS PROVIDER USING FAKESTORE API
final productsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response =
      await http.get(Uri.parse('https://fakestoreapi.com/products'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.cast<Map<String, dynamic>>();
  } else {
    throw Exception("Failed to load products");
  }
});

// ✅ LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/products');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter username & password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

// ✅ PRODUCTS SCREEN (DISPLAY PRODUCT CARDS IN GRID)
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nica x Aly"),
        backgroundColor: const Color.fromARGB(255, 96, 136, 189),
      ),
      body: productsAsyncValue.when(
        data: (products) => GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.70,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Error loading products: $err")),
      ),
    );
  }
}

// ✅ CUSTOM PRODUCT CARD WIDGET
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ IMAGE & RATING STACK
          Stack(
            children: [
              Image.network(
                product["image"],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 120,
                  color: Colors.grey,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 180,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ RATING BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF216594),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "${product["rating"]["rate"]} ⭐",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8), // Space between badges
                      // ✅ ORDER COUNT BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 148, 99, 44),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "🛒 ${product["rating"]["count"]}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ✅ PRODUCT DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ PRODUCT TITLE
                  Text(
                    product["title"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // ✅ PRODUCT PRICE
                  Text(
                    "\$${product["price"].toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 48, 87, 138),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ✅ PRODUCT CATEGORY
                  Text(
                    product["category"],
                    style: const TextStyle(
                        fontSize: 12, color: Color.fromARGB(255, 121, 58, 39)),
                  ),
                  const SizedBox(height: 4),
                  // ✅ DESCRIPTION WITH PROPER SPACE
                  Container(
                    height: 40, // Set desired height for the scrollable area
                    child: SingleChildScrollView(
                      child: Text(
                        product["description"],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
