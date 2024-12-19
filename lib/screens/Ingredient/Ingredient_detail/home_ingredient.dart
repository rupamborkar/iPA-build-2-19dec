import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Ingredient_detail/ingredient_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:enefty_icons/enefty_icons.dart';

class HomePage extends StatefulWidget {
  final String jwtToken;
  const HomePage({
    Key? key,
    required this.jwtToken,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchIngredients() async {
    try {
      print("Token: ${widget.jwtToken}");

      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/'), // Ensure correct API endpoint
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );
      print('Requesting ingredients from: $baseUrl/api/ingredients');
      print('Headers: ${{
        'Authorization': 'Bearer ${widget.jwtToken}',
      }}');
      print('Response body: ${response.body}'); // Debugging print statement
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ingredients = data
              .map((ingredient) => ingredient as Map<String, dynamic>)
              .toList();
          filteredIngredients = ingredients;
        });
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (error) {
      print('Error fetching ingredients: $error');
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredIngredients = ingredients.where((ingredient) {
        return ingredient['name']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Search bar
                Expanded(
                  child: Container(
                    height: 32,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search for Ingredient',
                                hintStyle: AppTextStyles.hintFormat,
                                // hintStyle: TextStyle(
                                //     fontSize: 13,
                                //     fontWeight: FontWeight.w300,
                                //     color: Color.fromRGBO(101, 104, 103, 1)),
                                prefixIcon: Icon(
                                  EneftyIcons.search_normal_2_outline,
                                  //Icons.search,
                                  size: 20,
                                  color: Color.fromRGBO(101, 104, 103, 1),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(231, 231, 231, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, size: 18),
                    onPressed: () {
                      // Handle filter action
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: filteredIngredients.map((ingredient) {
                  return IngredientCard(
                    id: ingredient['id'],
                    name: ingredient['name'] ?? 'Unknown',
                    category: ingredient['category'] ?? 'Unknown',
                    price: ingredient['price'] ?? 'N/A',
                    qtyPurchased: ingredient['quantity_purchased'] ?? 'N/A',
                    weight: ingredient['weight'] ?? 'N/A',
                    date: ingredient['last_update'] ?? '',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IngredientDetail(
                            name: ingredient['name'] ?? 'Unknown',
                            ingredientId: ingredient['id'],
                          ),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          // Trigger a rebuild or refresh your data here
                          _fetchIngredients(); // Example: Fetch updated ingredients
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String price;
  final String qtyPurchased;
  final String weight;
  final String date;
  final VoidCallback onTap;

  const IngredientCard({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.qtyPurchased,
    required this.weight,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color.fromRGBO(253, 253, 253, 1),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.nameFormat,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(230, 242, 242, 1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.categoryFormat,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: AppTextStyles.dateFormat,
                ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Color.fromRGBO(230, 242, 242, 1)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('\$${price}', 'Price'),
                  _buildInfoColumn(qtyPurchased, 'Qty Purchased'),
                  _buildInfoColumn(weight, 'Weight'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          value,
          style: AppTextStyles.valueFormat,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
      ]),
    );
  }
}
