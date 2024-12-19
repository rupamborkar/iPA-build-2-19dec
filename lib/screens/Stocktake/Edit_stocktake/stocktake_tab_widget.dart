import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StocktakeTabsWidget extends StatefulWidget {
  final bool isEditing;
  final Function onSave;
  final String stocktakeId;
  final int ingredientId;

  const StocktakeTabsWidget(
      {Key? key,
      required this.isEditing,
      required this.onSave,
      required this.stocktakeId,
      required this.ingredientId})
      : super(key: key);

  @override
  State<StocktakeTabsWidget> createState() => _StocktakeTabsWidgetState();
}

class _StocktakeTabsWidgetState extends State<StocktakeTabsWidget> {
  String? selectedUnit;
  final List<String> massUnits = [
    'gm',
    'kg',
    'oz',
    'lbs',
    'tonne',
    'ml',
    'cl',
    'dl',
    'L',
    'Pint',
    'Quart',
    'fl oz',
    'gallon',
    'Each',
    'Serving',
    'Box',
    'Bag',
    'Can',
    'Carton',
    'Jar',
    'Punnet',
    'Container',
    'Packet',
    'Roll',
    'Bunch',
    'Bottle',
    'Tin',
    'Tub',
    'Piece',
    'Block',
    'Portion',
    'Dozen',
    'Bucket',
    'Slice',
    'Pinch',
    'Tray',
    'Teaspoon',
    'Tablespoon',
    'Cup'
  ]..sort;

  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage
  Map<String, dynamic>? stocktakeData;
  String? _jwtToken;

  // Controllers for the text fields
  TextEditingController stocktakeNameController = TextEditingController();
  TextEditingController originController = TextEditingController();
  TextEditingController totalItemsController = TextEditingController();
  TextEditingController totalValueController = TextEditingController();
  TextEditingController commentsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController wastageController = TextEditingController();

  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> ingredientIngredeintsList = [];

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

      await fetchStocktakeDetails();
      await fetchIngredientsDetails();
      await fetchIngredients();
    } catch (e) {
      print("Error loading token or fetching stocktake details: $e");
    }
  }

  Future<void> fetchStocktakeDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stocktake/${widget.stocktakeId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          stocktakeData = data;

          // Update TextEditingControllers directly
          stocktakeNameController.text = data['name'] ?? '';
          originController.text = data['origin'] ?? '';
          totalItemsController.text = data['total_items'] ?? '';
          totalValueController.text = data['total_value'] ?? '';
          commentsController.text = data['comments'] ?? '';
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
          final decodedBody = json.decode(response.body);

          if (decodedBody is List) {
            setState(() {
              ingredients =
                  decodedBody.map((e) => e as Map<String, dynamic>).toList();
            });
          } else {
            print('Unexpected data format for ingredients: $decodedBody');
          }
        });
      } else {
        print(
            'Failed to load stocktake data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stocktake data: $e');
    }
  }

  Future<void> fetchIngredients() async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/api/ingredients/ingredients_list_advanced'),
          headers: {
            'Authorization': 'Bearer $_jwtToken',
            'Content-Type': 'application/json',
          });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ingredientIngredeintsList = data
              .map((item) => {
                    'id': item['ingredient_id'].toString(),
                    'name': item['name'],
                    'quantity_unit': item['ingredient_quantity_unit'] ?? '',
                    'quantity': item['quantity'] ?? '',
                    'cost': item['ingredient_cost'] ?? '',
                    'wastage': item['wastage'] ?? '',
                    'cost_per_unit': item['cost_per_unit'] ?? 0.0,
                    'wastage_per_unit': item['wastage_per_unit'] ?? 0.0,
                  })
              .toList();
          ingredientIngredeintsList
              .sort((a, b) => a['name'].compareTo(b['name']));
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> deleteStocktakeIngredient(
      String stocktakeId, int ingredientId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/stocktake/$stocktakeId/stocktake_ingredients/$ingredientId'),
        headers: {
          'Authorization': 'Bearer $_jwtToken', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient deleted successfully')),
        );

        Navigator.of(context).pop(true); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete Ingredient.')),
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

  void duplicateIngredient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Ingredient with same name already added'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _showAddIngredientDialog(String stocktakeId) {
    String? selectedIngredientId;
    String? selectedUnit;
    TextEditingController quantityUnitController = TextEditingController();

    // Update cost dynamically based on quantity and cost per unit
    void _updateCost() {
      if (selectedIngredientId != null) {
        double quantity = double.tryParse(quantityController.text) ?? 0.0;
        double costPerUnit = ingredientIngredeintsList.firstWhere(
              (ingredient) => ingredient['id'] == selectedIngredientId,
              orElse: () => {'cost_per_unit': 0.0},
            )['cost_per_unit'] ??
            0.0;

        double totalCost = quantity * costPerUnit;
        setState(() {
          costController.text = totalCost.toStringAsFixed(2);
        });
      }
    }

    // Update wastage dynamically based on quantity and wastage per unit
    void _updateWastage() {
      if (selectedIngredientId != null) {
        double quantity = double.tryParse(quantityController.text) ?? 0.0;
        double wastagePerUnit = ingredientIngredeintsList.firstWhere(
              (ingredient) => ingredient['id'] == selectedIngredientId,
              orElse: () => {'wastage_per_unit': 0.0},
            )['wastage_per_unit'] ??
            0.0;

        double totalWastage = quantity * wastagePerUnit;
        setState(() {
          wastageController.text = totalWastage.toStringAsFixed(2);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
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
                      value: selectedIngredientId,
                      items: ingredientIngredeintsList.map((ingredient) {
                        return DropdownMenuItem<String>(
                          value: ingredient['id'],
                          child: Text(ingredient['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedIngredientId = value;
                          final selectedIngredient =
                              ingredientIngredeintsList.firstWhere(
                                  (ingredient) => ingredient['id'] == value);
                          selectedUnit =
                              selectedIngredient['quantity_unit'] ?? '';
                          quantityUnitController.text = selectedUnit ?? '';
                          _updateCost();
                          _updateWastage();
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
                      menuMaxHeight: 400,
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
                          onChanged: (value) {
                            _updateCost();
                            _updateWastage();
                          },
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
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              _buildDisabledDialogTextField(
                'Wastage',
                wastageController,
              ),
              _buildDisabledDialogTextField(
                'Cost',
                costController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedIngredientId != null &&
                    quantityController.text.isNotEmpty) {
                  _updateCost();
                  _updateWastage();

                  final ingredientData = {
                    'ingredient_id': selectedIngredientId,
                    'quantity': double.tryParse(quantityController.text) ?? 0.0,
                    'quantity_unit': selectedUnit,
                    'cost': double.tryParse(costController.text) ?? 0.0,
                    'wastage': double.tryParse(wastageController.text) ?? 0.0,
                  };

                  try {
                    final response = await http.post(
                      Uri.parse(
                          '$baseUrl/api/stocktake/$stocktakeId/add_ingredient'),
                      headers: {
                        'Authorization': 'Bearer $_jwtToken',
                        'Content-Type': 'application/json',
                      },
                      body: json.encode(ingredientData),
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Ingredient added successfully')));
                    } else if (response.statusCode == 403) {
                      duplicateIngredient(context);
                    } else {
                      // Handle error
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Failed to add ingredient')));
                    }
                  } catch (e) {
                    print("Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error occurred')));
                  }
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisabledDialogTextField(
    String label,
    TextEditingController controller,
    // Function(String) onChanged,
    {
    bool isNumeric = false,
    // required TextEditingController controller
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 353,
        height: 40,
        child: TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          //onChanged: onChanged,
          enabled: false,
        ),
      ),
    );
  }

  void confirmDelete(ingredeintId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this ingredient from stocktake?'),
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
                deleteStocktakeIngredient(widget.stocktakeId, ingredeintId
                    // widget
                    //     .ingredientId
                    ); // Call deleteStocktakeIngredient with the ingredeint ID
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

  Future<void> updateStocktake() async {
    if (_jwtToken == null) return;

    final updatedData = {
      "stocktake_name": stocktakeNameController.text,
      "origin": originController.text,
      // "total_items": int.parse(totalItemsController.text),
      // "total_value": double.parse(totalValueController.text),
      "comments": commentsController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/stocktake/${widget.stocktakeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stocktake updated successfully!')),
        );
        //print('Stocktake updated successfully');
        widget.onSave();
      } else {
        print(
            'Failed to update stocktake. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating stocktake: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color.fromRGBO(0, 128, 128, 1),
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: 'Details'),
            Tab(text: 'Ingredients'),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDetailsTab(),
            _buildIngredientsTab(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: updateStocktake,
            child: Text(
              widget.isEditing ? 'Update' : 'Save',
              style: AppTextStyles.buttonText,
              // style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: AppStyles.elevatedButtonStyle,
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Color.fromRGBO(0, 128, 128, 1),
            //   padding: EdgeInsets.symmetric(vertical: 16.0),
            // ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(String label, Function(String) onChanged,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildTextFieldWithLabel('Stocktake Name *', stocktakeNameController,
              stocktakeData?['name']),
          _buildTextFieldWithLabel(
              'Origin', originController, stocktakeData?['origin']),
          _buildDisabledTotItemTextField('Total Items',
              stocktakeData?['total_items'], stocktakeData?['total_items']),
          _buildDisabledTotItemTextField('Total Value',
              stocktakeData?['total_values'], stocktakeData?['total_values']),
          _buildTextFieldWithLabel(
              'Comments', commentsController, stocktakeData?['comments']),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
      String label, TextEditingController controller, initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: AppTextStyles.labelFormat,
              children: [
                if (label.contains('*'))
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
          ),
          // Text(
          //   label,
          //   style: AppTextStyles.labelFormat,
          // ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              //initialValue: initialValue,
              controller: controller,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (value) {
                if (label.contains('*') &&
                    (value == null || value.trim().isEmpty)) {
                  return '${label.replaceAll('*', '').trim()} is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTotItemTextField(
      String label, String? value, String? initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.labelFormat,
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 353, // Fixed width of 353px
            height: 40,
            child: TextFormField(
              controller:
                  TextEditingController(text: initialValue ?? value ?? 'N/A'),
              decoration: InputDecoration(
                hintStyle: AppTextStyles.valueFormat,

                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(231, 231, 231, 1)!,
                      width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor:
                    Color.fromRGBO(231, 231, 231, 1), // Grey background color
                filled: true, // To make the fill color visible
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTextField(String label, String hint, initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.labelFormat,
              // style: TextStyle(
              //   color: Color.fromRGBO(150, 152, 151, 1),
              //   fontSize: 13,
              //   height: 1.5,
              //   fontWeight: FontWeight.w500,
              // ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 353, // Fixed width of 353px
            height: 40,
            child: TextFormField(
              initialValue: initialValue.toString(),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.valueFormat,

                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(231, 231, 231, 1)!,
                      width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor:
                    Color.fromRGBO(231, 231, 231, 1), // Grey background color
                filled: true, // To make the fill color visible
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add ingredient',
                style: AppTextStyles.labelBoldFormat,
                // style: TextStyle(
                //     fontFamily: 'Poppins',
                //     fontSize: 15,
                //     fontWeight: FontWeight.w500,
                //     height: 1.5,
                //     color: Color.fromRGBO(10, 15, 13, 1)),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Color.fromRGBO(101, 104, 103, 1),
                ),
                onPressed: () {
                  _showAddIngredientDialog(widget.stocktakeId);
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ...ingredients.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
            child: Card(
              color: Color.fromRGBO(253, 253, 253, 1),
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                    color: Color.fromRGBO(231, 231, 231, 1)!, width: 1),
              ),
              child: Column(
                children: [
                  ExpansionTile(
                    title: Text(
                      ingredient['name'] ?? 'Unknown Ingredient',
                      style: AppTextStyles.labelBoldFormat,
                      // style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    children: [
                      _buildQuantityAndUnitFields(
                        index: index,
                        ingredient: ingredient,
                      ),
                      _buildDisabledTextField(
                        'Wastage Percent',
                        ingredient['wastage'].toString(),
                        ingredient['wastage'],
                      ),
                      _buildDisabledTextField(
                        'Cost',
                        ingredient['cost'].toString(),
                        ingredient['cost'],
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // delete logic here
                        confirmDelete(ingredient['id']);
                      },
                      child: const Text(
                        'Delete Ingredient',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuantityAndUnitFields({
    required int index,
    required Map<String, dynamic> ingredient,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity Required',
            style: AppTextStyles.labelFormat,
            // style: TextStyle(
            //   color: Color.fromRGBO(150, 152, 151, 1),
            //   fontSize: 13,
            //   height: 1.5,
            //   fontWeight: FontWeight.w500,
            // ),
          ),
          const SizedBox(height: 8.0), // Space between label and fields
          Row(
            children: [
              SizedBox(
                width: 130.0, // Adjust the width as needed
                height: 40,
                child: TextFormField(
                  initialValue: ingredient['quantity'].toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    // hintText: '20',
                    hintStyle: AppTextStyles.valueFormat,
                    // const TextStyle(
                    //     fontSize: 13,
                    //     height: 1.5,
                    //     fontWeight: FontWeight.w300,
                    //     color: Color.fromRGBO(10, 15, 13, 1)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    //isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 8.0),
                  ),
                  enabled: false,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 210.0,
                height: 40,
                child: DropdownButtonFormField<String>(
                  value:
                      //ingredient['quantity_unit'],
                      selectedUnit,
                  hint: const Text(
                    'kg',
                    style: AppTextStyles.valueFormat,
                  ),
                  items: massUnits.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 8.0),
                  ),
                  dropdownColor: Color.fromRGBO(253, 253, 253, 1),
                  menuMaxHeight: 400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
