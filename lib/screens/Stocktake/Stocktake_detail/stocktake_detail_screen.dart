import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Stocktake/Edit_stocktake/add_ingredient_Screen.dart';
import 'package:flutter_app_login/screens/Stocktake/Edit_stocktake/edit_stocktake_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StocktakeDetailScreen extends StatefulWidget {
  final String stocktakeId;
  final String stocktakeName;

  const StocktakeDetailScreen(
      {super.key, required this.stocktakeId, required this.stocktakeName});

  @override
  _StocktakeDetailScreenState createState() => _StocktakeDetailScreenState();
}

class _StocktakeDetailScreenState extends State<StocktakeDetailScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage
  Map<String, dynamic>? stocktakeData;
  List<dynamic> ingredients = [];
  String? _jwtToken;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      // Retrieve JWT token from secure storage
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchStocktakeDetails();
      await fetchIngredientsDetails();
    } catch (e) {
      print("Error loading token or fetching stocktake details: $e");
    }
  }

  Future<void> fetchStocktakeDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        // Uri.parse('$baseUrl/api/stocktake/${widget.stocktakeId}/full'),
        Uri.parse('$baseUrl/api/stocktake/${widget.stocktakeId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          stocktakeData = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load stocktake data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stocktake data: $e');
    }
  }

  Future<void> fetchIngredientsDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/stocktake/${widget.stocktakeId}/stocktake_ingredients'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          ingredients = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load stocktake data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stocktake data: $e');
    }
  }

  Future<void> deleteStocktake(String stocktakeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/stocktake/$stocktakeId'),
        headers: {
          'Authorization': 'Bearer $_jwtToken', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stocktake deleted successfully')),
        );
        Navigator.of(context).pop(true); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete sstocktaker.')),
        );
      }
    } catch (e) {
      print('Error deleting stocktake: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the stocktake.')),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this stocktake?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteStocktake(widget
                    .stocktakeId); // Call deleteSupplier with the supplier ID
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Color.fromRGBO(101, 104, 103, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          //'April 2024',
          widget.stocktakeName,
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () async {
              if (_tabController.index == 0) {
                // Navigate to EditStocktakeScreen if on Details tab
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditStocktakeScreen(
                            stocktakeId: widget.stocktakeId,
                            ingredientId: 0,
                          )),
                );

                if (result == true) {
                  setState(() {
                    fetchStocktakeDetails();
                    fetchIngredientsDetails();
                  });
                }
              } else if (_tabController.index == 1) {
                // Navigate to AddIngredientScreen if on Ingredients tab
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddIngredientScreen(
                          stocktakeId: widget.stocktakeId, ingredientId: 0
                          // ingredientId: ingredients[0]['id'],
                          )),
                );
                if (result == true) {
                  setState(() {
                    fetchStocktakeDetails();
                    fetchIngredientsDetails();
                  });
                }
              }
            },
          ),
        ],
        bottom: TabBar(
          labelColor: Color.fromRGBO(0, 128, 128, 1),
          unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
          indicatorColor: Color.fromRGBO(0, 128, 128, 1),
          labelStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          controller: _tabController,
          tabs: [
            Tab(text: 'Details'),
            Tab(text: 'Ingredients'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildIngredientsTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Card(
      color: Color.fromRGBO(253, 253, 253, 1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Adjust radius for roundness
        side: BorderSide(
            color: Color.fromRGBO(231, 231, 231, 1)!,
            width: 1), // Border color and width
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Stocktake Name:', stocktakeData?['name'] ?? 'N/A'),
            _buildDetailRow('Origin:', stocktakeData?['origin'] ?? 'N/A'),
            _buildDetailRow(
                'Total Items:', stocktakeData?['total_items'].toString() ?? ''),
            _buildDetailRow('Total Value:',
                stocktakeData?['total_values'].toString() ?? ''),
            _buildDetailRow(
                'Last Update:', stocktakeData?['last_update'] ?? 'N/A'),
            _buildDetailRow('Comments:', stocktakeData?['comments'] ?? 'N/A'),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Handle delete action
                confirmDelete();
              },
              child: const Text(
                'Delete Stocktake',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Card(
          color: Color.fromRGBO(253, 253, 253, 1),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
          ),
          child: ExpansionTile(
            title: Text(
              ingredient['name'] ?? 'Unknown',
              style: AppTextStyles.labelBoldFormat,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Ingredient Name:', ingredient['name'] ?? 'Unknown'),
                    _buildDetailRow('Measurement:',
                        '${ingredient['quantity']} ${ingredient['quantity_unit']}'),
                    _buildDetailRow('Cost:', '\$${ingredient['cost'] ?? 0}'),
                    _buildDetailRow('Wastage:', '${ingredient['wastage']}'),
                    // _buildDetailRow('Wastage:',
                    //     '${ingredient['wastage_type']} (${ingredient['wastage_percent'] ?? 0}%)'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: AppTextStyles.labelFormat,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: AppTextStyles.valueFormat,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
