import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drink Selector',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/drinks': (context) => const DrinksScreen(),
      },
    );
  }
}

// ✅ DRINKS PROVIDER USING COCKTAILDB API
final drinksProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final response = await http.get(Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Coffee / Tea'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    List<dynamic> drinksList = jsonData['drinks'];

    return drinksList.map((drink) {
      return {
        "name": (drink["strDrink"] ?? "Unnamed Drink").toString(),
        "image": (drink["strDrinkThumb"] ?? "https://via.placeholder.com/150").toString(),
        "id": (drink["idDrink"] ?? "Unknown").toString(),
      };
    }).toList();
  } else {
    throw Exception("Failed to load drinks");
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
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/drinks');
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
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

// ✅ DRINKS SCREEN (DISPLAYS LIST OF DRINKS)
class DrinksScreen extends ConsumerWidget {
  const DrinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drinksAsyncValue = ref.watch(drinksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Select a Drink")),
      body: drinksAsyncValue.when(
        data: (drinks) => ListView.builder(
          itemCount: drinks.length,
          itemBuilder: (context, index) {
            final drink = drinks[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Image.network(
                  drink["image"]!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
                title: Text(drink["name"]!),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("You selected: ${drink["name"]}")),
                  );
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading drinks: $err")),
      ),
    );
  }
}
