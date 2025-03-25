import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
