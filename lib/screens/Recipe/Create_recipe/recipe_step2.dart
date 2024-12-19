import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeStep2 extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final Function(List<dynamic>) onIngredientsChange;

  const RecipeStep2(
      {super.key, required this.recipeData, required this.onIngredientsChange});

  @override
  _RecipeStep2State createState() => _RecipeStep2State();
}

class _RecipeStep2State extends State<RecipeStep2> {
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
  List<Map<String, dynamic>> ingredients = [];
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  List<Map<String, dynamic>> ingredientList = [];
  List<TextEditingController> qtyControllers = [];
  List<TextEditingController> costControllers = [];
  List<TextEditingController> wastageControllers = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
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
      await fetchIngredientList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchIngredientList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/ingredients_list_advanced'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        setState(() {
          ingredientList = fetchedData.map((item) {
            return {
              'id': item['ingredient_id'].toString(),
              'name': item['name'],
              'quantity_unit': item['ingredient_quantity_unit'] ?? '',
              'cost_per_unit': item['cost_per_unit'] ?? 0.0,
              'wastage_per_unit': item['wastage_per_unit'] ?? 0.0,
            };
          }).toList();

          ingredientList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  void _addIngredient() {
    setState(() {
      ingredients.add({
        "id": "",
        "quantity": "",
        "quantity_unit": "kg",
        "cost": "",
        "wastage": "",
      });
      qtyControllers.add(TextEditingController());
      costControllers.add(TextEditingController());
      wastageControllers.add(TextEditingController());
      widget.onIngredientsChange(ingredients);
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
      widget.onIngredientsChange(ingredients);
    });
  }

  void _onQuantityChanged(int index) {
    final ingredientId = ingredients[index]["id"];
    if (ingredientId == null || ingredientId.isEmpty) return;

    final selectedIngredient = ingredientList.firstWhere(
        (ingredient) => ingredient['id'] == ingredientId,
        orElse: () => {});
    if (selectedIngredient.isEmpty) return;

    final costPerUnit = selectedIngredient['cost_per_unit'] as double;
    final wastagePerUnit = selectedIngredient['wastage_per_unit'] as double;
    final quantity = double.tryParse(qtyControllers[index].text) ?? 0.0;

    final totalCost = quantity * costPerUnit;
    final totalWastage = quantity * wastagePerUnit;

    setState(() {
      costControllers[index].text = totalCost.toStringAsFixed(2);
      wastageControllers[index].text = totalWastage.toStringAsFixed(2);
      ingredients[index]["quantity"] = quantity;
      ingredients[index]["cost"] = totalCost;
      ingredients[index]["wastage"] = totalWastage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Add Ingredients',
                  style: AppTextStyles.labelBoldFormat,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIngredient,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                List<Map<String, dynamic>> availableIngredients = ingredientList
                    .where((ingredient) => !ingredients.any((e) =>
                        e['id'] == ingredient['id'] && e != ingredients[index]))
                    .toList();

                return Card(
                  color: Color.fromRGBO(253, 253, 253, 1),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                        color: Color.fromRGBO(231, 231, 231, 1), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDropdownIngreField(
                          'Ingredient Name',
                          items: availableIngredients,
                          onChanged: (value) {
                            setState(() {
                              ingredients[index]["id"] = value ?? '';
                            });
                            widget.onIngredientsChange(ingredients);
                          },
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Qty Purchased',
                              style: AppTextStyles.labelFormat,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 140.0,
                                  height: 40,
                                  child: TextFormField(
                                    controller: qtyControllers[index],
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => _onQuantityChanged(index),
                                    decoration: InputDecoration(
                                      hintText: 'Enter Quantity',
                                      hintStyle: AppTextStyles.hintFormat,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width:
                                      190.0, // Adjust the width as needed to match the text field
                                  height: 40,

                                  child: TextFormField(
                                    initialValue: ingredients[index]
                                        ["quantity_unit"],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      // hintText: 'Enter weight',
                                      hintStyle: AppTextStyles.hintFormat,

                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                      errorStyle: const TextStyle(
                                          height: 0), // Prevent resizing
                                    ),
                                    onSaved: (value) {
                                      ingredients[index]["quantity_unit"] =
                                          value;
                                    },
                                    onChanged: null,
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        buildDisabledTextField(
                          'Cost',
                          costControllers[index].text,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 8),
                        buildDisabledTextField(
                          'Wastage',
                          wastageControllers[index].text,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => removeIngredient(index),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color.fromRGBO(244, 67, 54, 1),
                          ),
                          child: const Text('Delete Ingredient'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownField(String label, List<String> items,
      {required Function(dynamic value) onChanged, required value}) {
    return Column(
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
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,

          child: DropdownButtonFormField<String>(
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            // onChanged: (value) {},
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            //  isDense: true,

            menuMaxHeight: 400,
          ),
        ),
      ],
    );
  }

  Widget buildDropdownIngreField(String label,
      {required List<Map<String, dynamic>> items,
      required Function(dynamic value) onChanged}) {
    return Column(
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
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,

          child: DropdownButtonFormField<String>(
            isExpanded: true,
            hint: Text(
              'Select $label',
              style: AppTextStyles.hintFormat,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: onChanged,

            decoration: InputDecoration(
              // hintText: 'Select $label',
              // hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            //  isDense: true,
          ),
        ),
      ],
    );
  }

  Widget buildEditableTextField(String label, String hint,
      {required TextEditingController controller,
      required Function(String) onChanged}) {
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
          const SizedBox(height: 5.0),
          SizedBox(
            width: 353, // Fixed width of 353px
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndUnitFields(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qty Purchased',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 140.0,
              height: 40,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    ingredients[index]['quantity'] = value;
                    ingredients[index]['ingredient_cost'] = value;
                  });
                  widget.onIngredientsChange(ingredients);
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 200.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: massUnits
                        .contains(ingredients[index]['ingredient_weight_unit'])
                    ? ingredients[index]['ingredient_weight_unit']
                    : null, // Ensure value matches items
                // ingredients[index]['quantity_unit'], // Fetched value
                hint: const Text(
                  'bag',
                  style: AppTextStyles.hintFormat,
                ),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: null, // Disable dropdown
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTextField(String label,
      //String hint,
      {int maxLines = 1,
      Function(String)? onChanged,
      required TextInputType keyboardType,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
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
          const SizedBox(height: 8.0),
          SizedBox(
            width: 353, // Fixed width of 353px
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                //hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: maxLines,
              validator: (value) {
                if (label.contains('*') &&
                    (value == null || value.trim().isEmpty)) {
                  return '${label.replaceAll('*', '').trim()} is required';
                }
                return null;
              },
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDisabledTextField(String label, String hint,
      {required Null Function(dynamic value) onChanged}) {
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
          const SizedBox(height: 5.0),
          SizedBox(
            width: 353, // Fixed width of 353px
            height: 40,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey[300]!, width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Colors.grey[200], // Grey background color
                filled: true, // To make the fill color visible
              ),
              enabled: false,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
