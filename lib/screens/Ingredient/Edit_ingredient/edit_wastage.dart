//Updated code on 01-11-24
import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/edit_ingredient.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/edit_measurements.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/ingredient_tab.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Main content for the wastage tab
class EditWastageContent extends StatefulWidget {
  final String ingredientId;

  const EditWastageContent({
    required this.ingredientId,
    // required this.jwtToken,
    Key? key,
  }) : super(key: key);

  @override
  _EditWastageContentState createState() => _EditWastageContentState();
}

class _EditWastageContentState extends State<EditWastageContent> {
  bool _showWastageFields = false;

  Map<String, dynamic>? ingredientData;

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
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
  ]..sort();

  // Controllers for text fields
  late TextEditingController quantityController;
  late TextEditingController quantityUnitController;
  late TextEditingController wastageTypeController;
  late TextEditingController wastageQuantityController;
  late TextEditingController wastagePerController;
  late TextEditingController quantityUnitCombineController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTokenAndFetchDetails();

    wastageQuantityController.addListener(calculateWastagePercentage);
    quantityController.addListener(calculateWastagePercentage);
  }

  void _initializeControllers() {
    quantityController = TextEditingController();
    quantityUnitController = TextEditingController();
    wastageTypeController = TextEditingController();
    wastageQuantityController = TextEditingController();
    wastagePerController = TextEditingController();
    quantityUnitCombineController = TextEditingController();
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
    String quantity = data['quantity_purchased']?.toString() ?? '';
    String unit = data['quantity_unit'] ?? '';

    quantityUnitCombineController.text =
        quantity.isNotEmpty ? '$quantity $unit' : '';

    quantityController.text = data['quantity_purchased']?.toString() ?? '';
    quantityUnitController.text = data['quantity_unit'] ?? '';
    wastageTypeController.text = data['wastage_type'] ?? '';
    wastageQuantityController.text = data['wastage_quantity']?.toString() ?? '';
    wastagePerController.text = data['wastage_percentage']?.toString() ?? '';
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
          // 'quantity_purchased': quantityController.text,
          // 'quantity_unit': quantityUnitController.text,
          'wastage_type': wastageTypeController.text,
          'wastage_quantity': wastageQuantityController.text,
          'wastage_percentage': wastagePerController.text,
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

  void calculateWastagePercentage() {
    double wastage = double.tryParse(wastageQuantityController.text) ?? 0;
    double totalQuantity = double.tryParse(quantityController.text) ?? 1;

    if (totalQuantity > 0) {
      double wastagePercentage = (wastage / totalQuantity) * 100;

      setState(() {
        wastagePerController.text = wastagePercentage.toStringAsFixed(2);
      });
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    quantityUnitController.dispose();
    wastageTypeController.dispose();
    wastageQuantityController.dispose();
    wastagePerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Add Wastage',
                      style: AppTextStyles.labelBoldFormat,
                    ),
                    IconButton(
                      icon: Icon(
                        _showWastageFields ? Icons.remove : Icons.add,
                        color: Color.fromRGBO(101, 104, 103, 1),
                      ),
                      onPressed: () {
                        setState(() {
                          _showWastageFields = !_showWastageFields;
                        });
                      },
                    ),
                  ],
                ),
                if (_showWastageFields)
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
                      padding:
                          const EdgeInsets.all(12.0), // Padding as specified
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),

                          // _buildDisabledTextField(
                          //     'Quantity Purchased', quantityController),
                          _buildDisabledTextField('Quantity Purchased',
                              quantityUnitCombineController),
                          SizedBox(height: 16),
                          _buildTextField(
                              'Wastage Type', wastageTypeController),
                          SizedBox(height: 16),
                          _buildTextField(
                              'Wastage Quantity', wastageQuantityController,
                              isNumber: true),
                          SizedBox(height: 16),

                          SizedBox(height: 16),
                          _buildDisabledTextField(
                              'Wastage %', wastagePerController,
                              isNumber: true),
                          SizedBox(height: 16),
                          // TextButton(
                          //   onPressed: () {
                          //     // Handle deletion logic here
                          //   },
                          //   child: Text(
                          //     'Delete Wastage',
                          //     style: TextStyle(color: Colors.red),
                          //   ),
                          // ),
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
              //width: double.infinity,
              width: 353,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle update logic here
                  _updateIngredientDetails();
                },
                style: AppStyles.elevatedButtonStyle,
                child: Text(
                  'Update',
                  style: AppTextStyles.buttonText,
                  // style: TextStyle(
                  //     fontSize: 15,
                  //     height: 1.5,
                  //     color: Color.fromRGBO(253, 253, 253, 1)),
                ),
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: Color.fromRGBO(0, 128, 128, 1),
                // ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40, // Fixed height of 40px
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              //hintText: hint,
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
}

Widget _buildDisabledTextField(String label, TextEditingController controller,
    {bool isNumber = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 329, // Fixed width of 353px
          height: 40, // Fixed height of 40px
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              //  hintText: hint,

              hintStyle: AppTextStyles.valueFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1.0, style: BorderStyle.solid),
              ),
              fillColor:
                  Color.fromRGBO(231, 231, 231, 1), // Grey background color
              filled: true, // To make the fill color visible
            ),
            enabled: false,
          ),
        )
      ],
    ),
  );
}

// Main widget for EditWastage with IngredientTabs
class EditWastage extends StatelessWidget {
  final String ingredientId;
  //final String jwtToken;

  const EditWastage({
    required this.ingredientId,
    //required this.jwtToken,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IngredientTabs(
      initialIndex: 2,
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
