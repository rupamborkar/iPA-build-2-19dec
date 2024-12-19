import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/edit_ingredient_recipe.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/edit_method.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/edit_tabs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeEditDetails extends StatefulWidget {
  final String recipeId;

  const RecipeEditDetails({super.key, required this.recipeId});

  @override
  State<RecipeEditDetails> createState() => _RecipeEditDetailsState();
}

class _RecipeEditDetailsState extends State<RecipeEditDetails> {
  String? selectedUnit;
  bool _useAsIngredient = false;
  String? comment;
  String? selectedCategory;
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
  ]..sort(); // List of mass units
  final List<String> recipeCategory = [
    'Appetiser',
    'Amuse bouche',
    'Starter',
    'Main',
    'Dessert',
    'Petit four',
    'Pre-dessert',
    'Mignardise',
    'Snack',
    'Salad',
    'Side',
    'Burger',
    'Sandwich',
    'Purée',
    'Sauce',
    'Dressing',
    'Pastry',
    'Jam',
    'Kitchen Recipe',
    'Ferments Preserved',
    'Pizza',
    'Other'
  ]..sort();

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<Map<String, dynamic>?>? recipeData;
  String? _jwtToken; // Initialize as nullable.

  late TextEditingController recipeNameController;
  late TextEditingController categoryController;
  late TextEditingController originController;
  late TextEditingController tagController;
  late TextEditingController servingController;
  late TextEditingController unitController;
  late TextEditingController costController;
  late TextEditingController sellingPController;
  late TextEditingController taxController;
  late TextEditingController foodCController;
  late TextEditingController netEController;
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTokenAndFetchDetails();
  }

  void _initializeControllers() {
    recipeNameController = TextEditingController();
    categoryController = TextEditingController();
    originController = TextEditingController();
    tagController = TextEditingController();
    servingController = TextEditingController();
    costController = TextEditingController();
    sellingPController = TextEditingController();
    taxController = TextEditingController();
    foodCController = TextEditingController();
    netEController = TextEditingController();
    commentController = TextEditingController();
    unitController = TextEditingController();
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
        recipeData = fetchRecipeDetails(); // Fetch details once token is set.
      });
    } catch (e) {
      print("Error loading token or fetching recipe details: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    if (_jwtToken == null) {
      throw Exception('JWT token is null');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
        },
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
        // final data = jsonDecode(response.body);

        // return data;
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
    }
  }

  void _populateControllers(Map<String, dynamic> data) {
    recipeNameController.text = data['name'] ?? '';
    categoryController.text = data['category'] ?? '';
    originController.text = data['origin'] ?? '';
    tagController.text = data['tags'] ?? [];
    servingController.text = data['serving_quantity']?.toString() ?? '';
    costController.text = data['cost']?.toString() ?? '';
    sellingPController.text = data['selling_price']?.toString() ?? '';
    taxController.text = data['tax']?.toString() ?? '';
    foodCController.text = data['food_cost']?.toString() ?? '';
    netEController.text = data['net_earnings']?.toString() ?? '';
    commentController.text = data['comments'] ?? '';
    unitController.text = data['serving_quantity_unit'] ?? '';
    selectedCategory = data['category'];

    // setState(() {
    //   // selectedUnit = data['quantity_unit'];
    //   selectedCategory = data['category']; // Add this variable if not present
    // });
  }

  Future<void> updateRecipeDetails() async {
    if (_jwtToken == null) {
      throw Exception('JWT token is null');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': recipeNameController.text,
          'category': categoryController.text,
          'origin': originController.text,
          'tags': tagController.text,
          'serving_quantity': servingController.text,
          'cost': costController.text,
          'selling_price': sellingPController.text,
          'tax': taxController.text,
          'food_cost': foodCController.text,
          'net_earnings': netEController.text,
          'serving_quantity_unit': selectedUnit,
          // 'unit': unitController.text,
          'comments': commentController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to update recipe');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: recipeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading recipe: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            if (data != null) {
              // Populate controllers if data is available
              _populateControllers(data);
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField('Recipe Name *', recipeNameController),
                        const SizedBox(height: 15),
                        buildDropdownField(
                          'Category *',
                          recipeCategory,
                          categoryController,
                          initialValue: data?['category'],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 200, // Set the max width as needed
                              ),
                              child:
                                  _buildTextField('Origin', originController),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Use as Ingredient?',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromRGBO(150, 152, 151, 1)),
                                  ),
                                  const SizedBox(height: 2),
                                  SizedBox(
                                    height: 42,
                                    child: ToggleButtons(
                                      isSelected: [
                                        _useAsIngredient,
                                        !_useAsIngredient
                                      ],
                                      onPressed: (int index) {
                                        setState(() {
                                          _useAsIngredient = index == 0;
                                        });
                                      },
                                      color: Colors.black,
                                      selectedColor:
                                          const Color.fromRGBO(0, 128, 128, 1),
                                      fillColor: const Color.fromRGBO(
                                          230, 242, 242, 1),
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderColor: const Color.fromRGBO(
                                          231, 231, 231, 1),
                                      selectedBorderColor:
                                          const Color.fromRGBO(0, 128, 128, 1),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.0, vertical: 10.0),
                                          child: Text('Yes'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.0, vertical: 10.0),
                                          child: Text('No'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildTextField('Tags', tagController),
                        const SizedBox(height: 15),

                        Text('Serving Size',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            )),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            SizedBox(
                              width: 140.0,
                              height: 40,
                              child: TextFormField(
                                controller: servingController,

                                //initialValue: data?['servingSize'],
                                //controller: servingController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  //hintText: '580',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 200.0,
                              height: 40,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: selectedUnit?.isEmpty ?? true
                                    ? unitController.text
                                    : selectedUnit,
                                hint: const Text(
                                  'ml',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 13,
                                      color: Color.fromRGBO(10, 15, 13, 1)),
                                ),
                                items: massUnits.map((String unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedUnit = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        //const SizedBox(width: 16),
                        const SizedBox(height: 15),
                        // _buildTextField('Serving Size', 'add serving size'),
                        // const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                                child: _buildRowDisabledTextField(
                                    'Cost', costController)),
                            const SizedBox(width: 4),
                            Expanded(
                                child:
                                    _buildRowTextField('Tax', taxController)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildRowTextField(
                                    'Selling Price', sellingPController)),
                            const SizedBox(width: 4),
                            Expanded(
                                child: _buildRowDisabledTextField(
                                    'Food Cost', foodCController)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDisabledTextField('Net Earnings', netEController),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Comments',
                          commentController,
                          maxLines: 3,
                          onChanged: (value) {
                            comment = value;
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        updateRecipeDetails();
                      },
                      style: AppStyles.elevatedButtonStyle,
                      child: const Text(
                        'Update',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    //String hint,
    {
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
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
                      color: Color.fromRGBO(244, 67, 54, 1),
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
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      const BorderSide(width: 168, style: BorderStyle.solid),
                ),
              ),
              // border:
              //     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              // onChanged: onChanged,
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
      ),
    );
  }

  Widget _buildRowTextField(
    String label,
    TextEditingController controller,
    //String hint,
    {
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
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
                      color: Color.fromRGBO(244, 67, 54, 1),
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 160, // Fixed width of 353px
            height: 40,
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
                      const BorderSide(width: 168, style: BorderStyle.solid),
                ),
              ),
              // border:
              //     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              onChanged: onChanged,
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
      ),
    );
  }

  Widget buildDropdownField(
      String label, List<String> items, TextEditingController controller,
      {required initialValue}) {
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
          width: 353,
          height: 40,
          child: DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty ? controller.text : null,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: SizedBox(
                  width: 150,
                  height: 40,
                  child: Text(item),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue;
                controller.text = newValue ?? '';
              });
            },
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppTextStyles.valueFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1.0, style: BorderStyle.solid),
              ),
            ),
            dropdownColor: Color.fromRGBO(253, 253, 253, 1),
            menuMaxHeight: 400,
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledTextField(
    String label,
    TextEditingController controller,
  ) {
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
            width: 353,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintStyle: AppTextStyles.valueFormat,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(width: 1.0, style: BorderStyle.solid)),
                fillColor: const Color.fromRGBO(231, 231, 231, 1),
                filled: true,
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDisabledTextField(
    String label,
    TextEditingController controller,
    //String hint
  ) {
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
            width: 160,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                //hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(width: 1.0, style: BorderStyle.solid)),
                fillColor: const Color.fromRGBO(
                    231, 231, 231, 1), // Grey background color
                filled: true, // To make the fill color visible
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qty Purchased',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              width: 150.0,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '1',
                  hintStyle: AppTextStyles.valueFormat,
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 200.0,
              child: DropdownButtonFormField<String>(
                value: selectedUnit,
                hint: const Text(
                  'bag',
                  style: AppTextStyles.valueFormat,
                ),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue;
                  });
                },
                validator: (value) {
                  if (selectedUnit == null) {
                    return 'Unit is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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

  @override
  void dispose() {
    recipeNameController.dispose();
    categoryController.dispose();
    originController.dispose();
    commentController.dispose();
    unitController.dispose();
    super.dispose();
  }
}

// Main widget for EditIngredient with IngredientTabs
class EditDetailsTab extends StatelessWidget {
  final String recipeId;

  const EditDetailsTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return RecipeTabs(
      initialIndex: 0,
      tabViews: [
        RecipeEditDetails(
          recipeId: recipeId,
        ),
        EditIngredientDetails(
          recipeId: recipeId,
        ),
        EditMethod(
          recipeId: recipeId,
        ),
      ],
    );
  }
}
