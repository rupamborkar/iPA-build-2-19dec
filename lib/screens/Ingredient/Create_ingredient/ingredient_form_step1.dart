import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Create_ingredient/form_fields.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientFormStep1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> data;

  const IngredientFormStep1({
    required this.formKey,
    required this.data,
    super.key,
  });

  @override
  State<IngredientFormStep1> createState() => _IngredientFormStep1State();
}

class _IngredientFormStep1State extends State<IngredientFormStep1> {
  String? selectedUnit; // Variable to hold selected unit

  String? selectedSupplierId;

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  // List<String> supplierList = [];
  List<Map<String, dynamic>> supplierList = [];
  final List<String> categories = [
    'Salad',
    'Herb',
    'Vegetable',
    'Mushroom',
    'Fresh Nut',
    'Meat',
    'Fruit',
    'Seafood',
    'Cured Meat',
    'Cheese',
    'Dairy',
    'Dry Good',
    'grain',
    'Flour',
    'Spices',
    'Chocolate',
    'Oil',
    'Vinegar',
    'Alcohol',
    'Bakery',
    'Flower',
    'Grains/Seeds',
    'Nuts',
    'Sugar',
    'Dryfruits',
    'Ice Cream',
    'Consumable',
    'Beverage',
    'Dessert',
    'Snack',
    'Drink'
  ]..sort();

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

  double Result = 0.0;
  void calculate() {
    final double price = widget.data['price'] is double
        ? widget.data['price'] as double
        : double.tryParse(widget.data['price'].toString()) ?? 0.0;

    final double tax = widget.data['tax'] is double
        ? widget.data['tax'] as double
        : double.tryParse(widget.data['tax'].toString()) ?? 0.0;

    final double result = price + ((price * tax) / 100);

    setState(() {
      Result = result;
      widget.data['cost'] = Result;
    });

    print('Price: $price, Quantity: $tax, Result: $Result');
  }

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

      await fetchSupplierList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchSupplierList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/supplier/supplier_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> suppData = json.decode(response.body);
        setState(() {
          supplierList = suppData.map((supplier) {
            return {
              'name': supplier['name'],
              'id': supplier['supplier_id'],
            };
          }).toList();

          supplierList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: widget.formKey,
            //return
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed title at the top
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Basic Details',
                    style: AppTextStyles.labelBoldFormat,
                  ),
                ),
                // Scrollable form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        buildTextField(
                          'Ingredient Name *',
                          'e.g. Carrot, Almond',
                          onSaved: (value) {
                            widget.data['name'] = value;
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        buildDropdownField(
                          'Category *',
                          categories,
                          onSaved: (value) {
                            widget.data['category'] = value;
                          },
                          onChanged: (value) {
                            widget.data['category'] = value;
                          },
                        ),
                        const SizedBox(height: 16),

                        buildDropdownField(
                          'Supplier *',
                          supplierList
                              .map((e) => e['name']! as String)
                              .toList(),
                          onSaved: (value) {
                            final selectedSupplier = supplierList.firstWhere(
                              (supplier) => supplier['name'] == value,
                            );
                            widget.data['supplier_id'] =
                                int.tryParse(selectedSupplier['id'] ?? '0') ??
                                    0;
                            //selectedSupplier['id'];
                          },
                          onChanged: (value) {
                            final selectedSupplier = supplierList.firstWhere(
                              (supplier) => supplier['name'] == value,
                            );
                            setState(() {
                              selectedSupplierId = selectedSupplier['id'];
                            });
                          },
                        ),

                        const SizedBox(height: 16),
                        buildTextField(
                          'Supplier Product Code',
                          'e.g. CB12234',
                          onSaved: (value) {
                            widget.data['product_code'] = value;
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        _buildQuantityAndUnitFields(),

                        const SizedBox(height: 16),

                        buildTextField(
                          'Tax (%)',
                          'Enter a tax %',
                          onSaved: (value) {
                            widget.data['tax'] =
                                double.tryParse(value ?? '1') ?? 0.0;
                            calculate();
                          },
                          // onChanged: (value) {},
                          onChanged: (value) {
                            setState(() {
                              widget.data['tax'] =
                                  double.tryParse(value) ?? 0.0;
                            });
                            calculate(); // Recalculate cost when the quantity is changed
                          },
                        ),
                        const SizedBox(height: 16),

                        buildTextField(
                          'Price',
                          'Enter a price',
                          onSaved: (value) {
                            widget.data['price'] =
                                int.tryParse(value ?? '0') ?? 0;
                            calculate(); // Recalculate cost when the price is saved
                          },
                          onChanged: (value) {
                            setState(() {
                              widget.data['price'] = int.tryParse(value) ?? 0;
                            });
                            calculate();
                            // onSaved: (value) {
                            //   widget.data['price'] = value;
                            // widget.data['price'] = int.tryParse(value) ?? 0;
                            // calculate(); // Recalculate cost on change
                          },
                        ),
                        const SizedBox(height: 16),
                        buildTextField(
                          'Comments',
                          'Enter the comments',
                          onSaved: (value) {
                            widget.data['comments'] = value;
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        // Next button can be added here
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity Purchased',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              width: 110.0,
              height: 40,
              child: TextFormField(
                //initialValue: widget.data['quantity'],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  hintStyle: AppTextStyles.hintFormat,

                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                onSaved: (value) {
                  widget.data['quantity'] = int.tryParse(value ?? '1') ?? 1;
                  //calculate(); // Recalculate cost when the quantity is saved
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit,
                hint: const Text(
                  'Select unit',
                  style: AppTextStyles.hintFormat,
                  //TextStyle(color: Colors.grey),
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
                    widget.data['quantity_unit'] = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                dropdownColor: Color.fromRGBO(253, 253, 253, 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
