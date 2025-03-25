import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ProviderScope(child: MyApp()));
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

// ✅ PROVIDER FOR FETCHING DRINKS FROM COCKTAILDB API
final drinksProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final response = await http.get(Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Coffee / Tea'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    List<dynamic> drinksList = jsonData['drinks'];

    return drinksList.map((drink) {
      return {
        "name": drink["strDrink"].toString(),
        "image": drink["strDrinkThumb"].toString(),
        "id": drink["idDrink"].toString(),
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

// ✅ DRINKS SCREEN
class DrinksScreen extends ConsumerStatefulWidget {
  const DrinksScreen({super.key});

  @override
  DrinksScreenState createState() => DrinksScreenState();
}

class DrinksScreenState extends ConsumerState<DrinksScreen> {
  String? selectedDrink;

  @override
  Widget build(BuildContext context) {
    final drinksAsyncValue = ref.watch(drinksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Select a Drink")),
      body: drinksAsyncValue.when(
        data: (drinks) => Column(
          children: [
            const SizedBox(height: 20),
            DropdownButton<String>(
              hint: const Text("Select a drink"),
              value: selectedDrink,
              items: drinks.map((drink) {
                return DropdownMenuItem<String>(
                  value: drink["name"],
                  child: Text(drink["name"] ?? ""),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDrink = value;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedDrink != null)
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "You selected: $selectedDrink",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.network(
                        drinks.firstWhere((drink) => drink["name"] == selectedDrink)["image"] ?? "",
                        height: 150,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading drinks: $err")),
      ),
    );
  }
}
