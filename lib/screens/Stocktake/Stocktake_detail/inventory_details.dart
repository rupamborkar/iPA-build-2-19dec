import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_app_login/constants/material.dart';
import 'package:http/http.dart' as http;

class InventoryPage extends StatefulWidget {
  final String token;
  const InventoryPage({super.key, required this.token});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredInventory = [];
  List<Map<String, dynamic>> ingredientDropdownList = [];
  List<dynamic> inventoryList = [];
  bool isLoading = true;
  String selectedCategory = ''; // Track selected category
  final List<String> Categories = ['Food', 'Beverage', 'Other'];

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
    fetchIngredientList();
    _searchController.addListener(_onSearchChanged);
  }

  // Fetch inventory data
  Future<void> fetchInventoryData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stocktake/get_inventory'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> rawInventoryList = json.decode(response.body);
        setState(() {
          inventoryList = rawInventoryList
              .map((item) => item as Map<String, dynamic>)
              .toList();
          filteredInventory = List.from(inventoryList);
          isLoading = false;
        });
      } else {
        print(
            'Failed to load inventory data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  // Fetch ingredient data
  Future<void> fetchIngredientList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/ingredients_list_advanced'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        setState(() {
          ingredientDropdownList = fetchedData.map((item) {
            return {
              'id': item['ingredient_id'].toString(),
              'name': item['name'],
              'quantity_unit': item['ingredient_quantity_unit'] ?? '',
              'quantity': item['quantity'] ?? '',
            };
          }).toList();
          ingredientDropdownList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

//   Handle search input changes
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredInventory = inventoryList
          .where((item) {
            final name = item['name'].toString().toLowerCase();
            return name.contains(query);
          })
          .map((item) => item as Map<String, dynamic>)
          .toList();
    });
  }

  // Handle category filter changes
  void _onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category ?? '';
      _filterInventoryByCategory();
    });
  }

  void _filterInventoryByCategory() {
    setState(() {
      filteredInventory = inventoryList
          .where((item) {
            final name = item['name'].toString().toLowerCase();
            final matchesCategory = selectedCategory.isEmpty ||
                item['category']
                    .toString()
                    .toLowerCase()
                    .contains(selectedCategory.toLowerCase());
            return name.contains(_searchController.text.toLowerCase()) &&
                matchesCategory;
          })
          .toList()
          .cast<Map<String, dynamic>>(); // Explicit cast here
    });
  }

  void _showAddIngredientDialog() {
    String? selectedIngredientName;
    String? selectedIngredientId;
    String? selectedUnit;

    TextEditingController quantityController = TextEditingController();
    TextEditingController quantityUnitController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Ingredient Name',
                        style: TextStyle(
                          color: Color.fromRGBO(150, 152, 151, 1),
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: 353,
                      height: 40,
                      child: DropdownButtonFormField<String>(
                        value: selectedIngredientName,
                        items: ingredientDropdownList
                            .map((ingredient) => DropdownMenuItem<String>(
                                  value: ingredient['name'],
                                  child: Text(ingredient['name']),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIngredientName = value;
                            final selected = ingredientDropdownList.firstWhere(
                              (element) => element['name'] == value,
                            );
                            selectedIngredientId = selected['id'];
                            selectedUnit = selected['quantity_unit'] ?? '';
                            quantityUnitController.text = selectedUnit ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select Ingredient',
                          hintStyle: const TextStyle(color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity Required',
                      style: TextStyle(
                        color: Color.fromRGBO(150, 152, 151, 1),
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: TextFormField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter quantity',
                              hintStyle: const TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromRGBO(150, 153, 151, 1)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                    color: Color.fromRGBO(231, 231, 231, 1)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 160,
                          height: 40,
                          child: TextFormField(
                            controller: quantityUnitController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromRGBO(150, 153, 151, 1)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                    color: Color.fromRGBO(231, 231, 231, 1)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                            ),
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            // Add Button
            TextButton(
              onPressed: () async {
                final ingredientData = {
                  'ingredient_id': selectedIngredientId,
                  'quantity': double.tryParse(quantityController.text) ?? 0.0,
                  'quantity_unit': selectedUnit,
                };

                try {
                  final response = await http.post(
                    Uri.parse('$baseUrl/api/stocktake/stock_out'),
                    headers: {
                      'Authorization': 'Bearer ${widget.token}',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode(ingredientData),
                  );

                  if (response.statusCode == 200) {
                    Navigator.of(context).pop(true);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Ingredient removed successfully')));
                  } else if (response.statusCode != 200) {
                    final data = json.decode(response.body);
                    final String message = data['message'] ?? '';
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Failed to remove ingredient')));
                  }
                } catch (e) {
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error occurred')));
                }
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                                hintText: 'Search',
                                hintStyle: AppTextStyles.hintFormat,
                                prefixIcon: Icon(
                                  EneftyIcons.search_normal_2_outline,
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(231, 231, 231, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory.isEmpty ? null : selectedCategory,
                      hint: const Icon(Icons.filter_list, size: 15),
                      icon: const SizedBox.shrink(),
                      alignment: Alignment.center,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        _onCategoryChanged(newValue);
                      },
                      items: Categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return Categories.map<Widget>((_) {
                          return const Icon(Icons.filter_list, size: 15);
                        }).toList();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredInventory.isEmpty
                      ? const Center(
                          child: Text(
                            "No matching inventory found",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(150, 152, 151, 1),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredInventory.length,
                          itemBuilder: (context, index) {
                            final item = filteredInventory[index];
                            return _buildInventoryCard(item);
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddIngredientDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  minimumSize: const Size(100, 40),
                ),
                child: const Text(
                  "Stockout",
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build inventory card widget
  Widget _buildInventoryCard(dynamic item) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side:
            const BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['name']}",
              style: AppTextStyles.nameFormat,
            ),
            const SizedBox(height: 8),
            const Divider(
              thickness: 1,
              color: Color.fromRGBO(230, 242, 242, 1),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildInfoColumn("Category", "${item['category']}"),
              _buildInfoColumn("Price per Unit", "${item['price_per_unit']}"),
              _buildInfoColumn("Total Quantity", "${item['total_quantity']}"),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.valueFormat),
      ],
    );
  }
}
