import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/edit_ingredient.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/edit_measurements.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/edit_wastage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientDetail extends StatefulWidget {
  final String ingredientId;
  final String name;

  IngredientDetail({required this.ingredientId, required this.name});

  @override
  _IngredientDetailState createState() => _IngredientDetailState();
}

class _IngredientDetailState extends State<IngredientDetail> {
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage
  Map<String, dynamic>? ingredientData;
  String? _jwtToken;
  final int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
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

      await fetchIngredientDetails();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchIngredientDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          ingredientData = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 15,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.name,
            style: AppTextStyles.heading,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Color.fromRGBO(101, 104, 103, 1)),
              onPressed: () async {
                if (_currentTabIndex == 0) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IngredientEdit(
                        ingredientId: widget.ingredientId,
                        jwtToken: _jwtToken!,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      fetchIngredientDetails();
                    });
                  }
                } else if (_currentTabIndex == 1) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditMeasurements(
                              ingredientId: widget.ingredientId,
                            )),
                  );

                  if (result == true) {
                    setState(() {
                      fetchIngredientDetails();
                    });
                  }
                } else if (_currentTabIndex == 2) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditWastage(ingredientId: widget.ingredientId)),
                  );

                  if (result == true) {
                    setState(() {
                      fetchIngredientDetails();
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
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Measurement'),
              Tab(text: 'Wastage'),
            ],
          ),
        ),
        body: ingredientData == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  DetailsTab(
                    ingredientData: ingredientData!,
                    jwtToken: _jwtToken!,
                  ),
                  MeasurementsTab(ingredientData: ingredientData!),
                  WastageTab(ingredientData: ingredientData!),
                ],
              ),
      ),
    );
  }
}

class DetailsTab extends StatefulWidget {
  final Map<String, dynamic> ingredientData;
  final String jwtToken;

  DetailsTab({required this.ingredientData, required this.jwtToken});

  @override
  _DetailsTabState createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  late BuildContext scaffoldContext;

  void duplicateIngredient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Ingredient is already present in recipe'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteIngredient(String ingredientId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/ingredients/$ingredientId'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(content: Text('Ingredient deleted successfully')),
        );
        Navigator.of(scaffoldContext).pop(true); // Pass 'true' as a result

        //Navigator.of(scaffoldContext).pop(); // Return to the previous screen
      } else if (response.statusCode == 403) {
        duplicateIngredient(context);
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete ingredient.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting ingredient: $e');
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the ingredient.')),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: scaffoldContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this ingredient?'),
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
                deleteIngredient(widget.ingredientData['id']);
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
    return Builder(
      builder: (BuildContext newContext) {
        // Save the context tied to the active Scaffold
        scaffoldContext = newContext;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color.fromRGBO(253, 253, 253, 1),
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Adjust radius for roundness
                  side: BorderSide(
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      width: 1), // Border color and width
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(
                          'Ingredient Name:', widget.ingredientData['name']),
                      _buildRow('Category:', widget.ingredientData['category']),
                      _buildRow('Supplier:', widget.ingredientData['supplier']),
                      _buildRow('Product Code:',
                          widget.ingredientData['product_code']),
                      _buildRow('Quantity Purchased:',
                          '${widget.ingredientData['quantity_purchased']} (${widget.ingredientData['quantity_unit']})'),

                      // '${ingredient['wastage_type']} (${ingredient['wastage_percent'] ?? 0}%)'),
                      _buildRow(
                          'Price:', '\$${widget.ingredientData['price']}'),
                      _buildRow('Tax:', '${widget.ingredientData['tax']}%'),
                      _buildRow('Cost:', '\$${widget.ingredientData['cost']}'),

                      _buildRow(
                          'Last Update', widget.ingredientData['last_update']),
                      _buildRow(
                          'Comments: ', widget.ingredientData['comments']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // Handle recipe deletion here
                    confirmDelete();
                  },
                  child: const Text(
                    'Delete ingredients',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(244, 67, 54, 1)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MeasurementsTab extends StatelessWidget {
  final Map<String, dynamic> ingredientData;

  MeasurementsTab({required this.ingredientData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromRGBO(253, 253, 253, 1),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0), // Adjust radius for roundness
          side: BorderSide(
              color: const Color.fromRGBO(231, 231, 231, 1),
              width: 1), // Border color and width
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('Qty Purchased:',
                  '${ingredientData['measurement_quantity']} ${ingredientData['measurement_unit']}'),
              _buildRow('Weight:',
                  '${ingredientData['weight']} ${ingredientData['weight_unit']}'),
              _buildRow('Cost:', '\$${ingredientData['measurement_cost']}'),
            ],
          ),
        ),
      ),
    );
  }
}

class WastageTab extends StatelessWidget {
  final Map<String, dynamic> ingredientData;

  WastageTab({required this.ingredientData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromRGBO(253, 253, 253, 1),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
              color: const Color.fromRGBO(231, 231, 231, 1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('Wastage Type:', ingredientData['wastage_type']),
              _buildRow('Wastage Percentage:',
                  '${ingredientData['wastage_percentage']}%'),
              _buildRow('Price:', '\$${ingredientData['wastage_price']}'),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildRow(String label, String value) {
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
            value.toString(),
            style: AppTextStyles.valueFormat,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    ),
  );
}
