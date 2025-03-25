import 'package:flutter/material.dart';

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
                  SizedBox(
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
