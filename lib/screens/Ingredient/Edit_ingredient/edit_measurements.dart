import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/edit_ingredient.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/edit_wastage.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/ingredient_tab.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMeasurementsContent extends StatefulWidget {
  final String ingredientId;

  const EditMeasurementsContent({
    required this.ingredientId,
    // required this.jwtToken,
    Key? key,
  }) : super(key: key);

  @override
  _EditMeasurementsContentState createState() =>
      _EditMeasurementsContentState();
}

class _EditMeasurementsContentState extends State<EditMeasurementsContent> {
  Map<String, dynamic>? ingredientData;

  bool _showMeasurementFields = false;

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  String? selectedUnit; // Variable to hold selected unit
  String? selectedWeightUnit;
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
  ]..sort();

  // Controllers for text fields
  late TextEditingController quantityController;
  late TextEditingController quantityUnitController;
  late TextEditingController weightController;
  late TextEditingController weightUnitController;
  late TextEditingController measurementCostController;
  late TextEditingController costController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTokenAndFetchDetails();
    // Add listener to weightController to calculate cost on text change
    weightController.addListener(() {
      calculateCost();
    });
  }

  void _initializeControllers() {
    quantityController = TextEditingController();
    quantityUnitController = TextEditingController();
    weightController = TextEditingController();
    weightUnitController = TextEditingController();
    measurementCostController = TextEditingController();
    costController = TextEditingController();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
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
        final data = json.decode(response.body);
        setState(() {
          ingredientData = data;
          _populateControllers(data);
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  void _populateControllers(Map<String, dynamic> data) {
    quantityController.text = data['measurement_quantity']?.toString() ?? '';
    quantityUnitController.text = data['measurement_unit'] ?? '';
    weightController.text = data['weight']?.toString() ?? '';
    weightUnitController.text = data['weight_unit'] ?? '';
    measurementCostController.text = data['measurement_cost']?.toString() ?? '';
    costController.text = data['cost']?.toString() ?? '';
  }

  Future<void> _updateIngredientDetails() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          //'name': quantityController.text,
          "measurement_quantity": quantityController.text,
          "measurement_unit": quantityUnitController.text,
          'weight': weightController.text,
          'weight_unit': weightUnitController.text,
          'measurement_cost': measurementCostController.text,
          // 'price': double.tryParse(costController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient updated successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to update ingredient details');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating ingredient: $error')),
      );
    }
  }

  void calculateCost() {
    // Parse inputs safely
    double price = double.tryParse(costController.text) ?? 0.0;
    double weight = double.tryParse(weightController.text) ?? 0.0;

    // Attempt to parse 'quantity_purchased' safely
    double quantityPurchased = double.tryParse(
            ingredientData?['quantity_purchased']?.toString() ?? '1') ??
        1.0; // Default to 1.0 for safety

    // Ensure no division by zero
    if (weight > 0 && quantityPurchased > 0) {
      double cost = (price * weight) / quantityPurchased;

      // Update the measurement cost controller
      setState(() {
        measurementCostController.text =
            cost.toStringAsFixed(2); // Round to 2 decimal places
      });
    } else {
      // Handle invalid calculations
      setState(() {
        measurementCostController.text = "0.00";
      });
      print(
          'Invalid inputs for calculation. Ensure weight and quantity are greater than zero.');
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    quantityUnitController.dispose();
    weightController.dispose();
    weightUnitController.dispose();
    measurementCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ingredientData == null) {
      return Scaffold(
        // appBar: AppBar(title: const Text('Edit Ingredient Details')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Measurement',
                      style: AppTextStyles.labelBoldFormat,
                    ),
                    IconButton(
                      icon: Icon(
                        _showMeasurementFields ? Icons.remove : Icons.add,
                        color: Color.fromRGBO(101, 104, 103, 1),
                      ),
                      onPressed: () {
                        setState(() {
                          _showMeasurementFields = !_showMeasurementFields;
                        });
                      },
                    ),
                  ],
                ),
                if (_showMeasurementFields)
                  Card(
                    elevation: 0,
                    color: Colors.white.withOpacity(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Color.fromRGBO(231, 231, 231, 1), width: 1),
                    ),
                    child: Container(
                      width: 353,
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          _buildQuantityAndUnitFields(),
                          SizedBox(height: 16),
                          _buildWeightAndUnitFields(),
                          SizedBox(height: 16),
                          _buildTextField('Cost', measurementCostController,
                              isNumber: true),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 353,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _updateIngredientDetails();
                },
                style: AppStyles.elevatedButtonStyle,
                child: Text(
                  'Update',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build dynamic fields using fetched data
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40, // Fixed height of 40px
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              // hintText: hint,
              hintStyle: AppTextStyles.valueFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1.0, style: BorderStyle.solid),
              ),
            ),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            //maxLines: maxLines,
            validator: (value) {
              if (label.contains('*') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Enter the ${label.replaceAll('*', '').trim()}';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qty Purchased',
          style: AppTextStyles.labelFormat,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 90,
              height: 40,
              child: TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  //hintText: '1',
                  hintStyle: AppTextStyles.valueFormat,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 220.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit ?? quantityUnitController.text,
                hint: Text(
                  'Bag',
                  style: AppTextStyles.valueFormat,
                ),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: SizedBox(
                      width: 150, // Set the width of the dropdown item
                      height: 40,
                      child: Text(unit),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue;
                    quantityUnitController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (selectedUnit == null) {
                    return 'Unit is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                ),
                dropdownColor: Color.fromRGBO(253, 253, 253, 1),
                menuMaxHeight: 400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight',
          style: AppTextStyles.labelFormat,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 90,
              height: 40,
              child: TextFormField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  // hintText: '1',
                  hintStyle: AppTextStyles.valueFormat,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  //isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 220.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedWeightUnit ?? weightUnitController.text,
                hint: Text(
                  'kg',
                  style: AppTextStyles.valueFormat,
                ),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: SizedBox(
                      width: 150, // Set the width of the dropdown item
                      height: 40,
                      child: Text(unit),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedWeightUnit = newValue;
                    weightUnitController.text = newValue ?? '';
                    calculateCost();
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  //  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                ),
                dropdownColor: Color.fromRGBO(253, 253, 253, 1),
                menuMaxHeight: 400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Main widget for EditMeasurements with IngredientTabs
class EditMeasurements extends StatelessWidget {
  final String ingredientId;
  //final String jwtToken;

  const EditMeasurements({
    required this.ingredientId,
    //required this.jwtToken,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IngredientTabs(
      initialIndex: 1,
      tabViews: [
        EditIngredientsDetail(
          ingredientId: ingredientId,
        ),
        EditMeasurementsContent(
          ingredientId: ingredientId,
        ),
        EditWastageContent(
          ingredientId: ingredientId,
        ),
      ],
    );
  }
}
