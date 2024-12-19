import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/edit_method.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/edit_recipe_details.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/edit_tabs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditIngredientDetails extends StatefulWidget {
  final String recipeId;
  const EditIngredientDetails({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _EditIngredientDetailsState createState() => _EditIngredientDetailsState();
}

class _EditIngredientDetailsState extends State<EditIngredientDetails> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  Future<Map<String, dynamic>?>? recipeData;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> ingredientDropdownList = [];
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
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController wastageController = TextEditingController();

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
      setState(() async {
        _jwtToken = token;
        recipeData = fetchRecipeDetails();
        await fetchIngredientList();
      });
    } catch (e) {
      print("Error loading token or fetching recipe details: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    if (_jwtToken == null) throw Exception('JWT token is null');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ingredients = List<Map<String, dynamic>>.from(data['ingredients']);
        });
        return data;
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
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
          ingredientDropdownList = fetchedData.map((item) {
            return {
              'id': item['ingredient_id'].toString(),
              'name': item['name'],
              'quantity_unit': item['ingredient_quantity_unit'] ?? '',
              'quantity': item['quantity'] ?? '',
              'cost': item['ingredient_cost'] ?? '',
              'wastage': item['wastage'] ?? '',
              'cost_per_unit': item['cost_per_unit'] ?? 0.0,
              'wastage_per_unit': item['wastage_per_unit'] ?? 0.0,
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

  void _toggleExpand(int index) {
    setState(() {
      ingredients[index]['expanded'] =
          !(ingredients[index]['expanded'] ?? false);
    });
  }

  Future<void> deleteIngredient(String ingredientId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}/$ingredientId'),
        headers: {
          'Authorization': 'Bearer ${_jwtToken}', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient deleted successfully')),
        );

        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete ingredient.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting ingredient: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the ingredient.')),
      );
    }
  }

  void confirmDelete(String ingredientId) {
    showDialog(
      context: context,
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
                deleteIngredient(ingredientId);
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

  void duplicateIngredient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Ingredient with same name already added'),
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

  void _showAddIngredientDialog(String recipeId) {
    String? selectedIngredientName;
    String? selectedIngredientId;
    String? selectedUnit;

    TextEditingController quantityController = TextEditingController();
    TextEditingController costController = TextEditingController();
    TextEditingController wastageController = TextEditingController();
    TextEditingController quantityUnitController = TextEditingController();

    // Function to update cost and wastage in real-time
    void _updateCostAndWastage() {
      if (selectedIngredientId != null) {
        double quantity = double.tryParse(quantityController.text) ?? 0.0;

        // Fetch cost per unit
        double costPerUnit = ingredientDropdownList.firstWhere(
              (ingredient) => ingredient['id'] == selectedIngredientId,
              orElse: () => {'cost_per_unit': 0.0},
            )['cost_per_unit'] ??
            0.0;

        // Fetch wastage per unit
        double wastagePerUnit = ingredientDropdownList.firstWhere(
              (ingredient) => ingredient['id'] == selectedIngredientId,
              orElse: () => {'wastage_per_unit': 0.0},
            )['wastage_per_unit'] ??
            0.0;

        // Calculate total cost and wastage
        double totalCost = quantity * costPerUnit;
        double totalWastage = quantity * wastagePerUnit;

        setState(() {
          costController.text = totalCost.toStringAsFixed(2);
          wastageController.text = totalWastage.toStringAsFixed(2);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ingredient Dropdown
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
                            _updateCostAndWastage(); // Update cost and wastage when ingredient is changed
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

                // Quantity and Unit Input
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
                        // Quantity Input
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
                              _updateCostAndWastage();
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

                _buildDisabledDialogTextField('Wastage', wastageController),
                _buildDisabledDialogTextField('Cost', costController),
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
                  'cost': double.tryParse(costController.text) ?? 0.0,
                  'wastage': double.tryParse(wastageController.text) ?? 0.0,
                };

                try {
                  final response = await http.post(
                    Uri.parse('$baseUrl/api/recipes/$recipeId/add_ingredient'),
                    headers: {
                      'Authorization': 'Bearer $_jwtToken',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode(ingredientData),
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    // Ingredient successfully added
                    Navigator.of(context).pop(true);
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

  Widget buildDropdownIngreField(String label,
      {required List<Map<String, dynamic>> items,
      required Function(dynamic value) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
                value: item['id'].toString(),
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: onChanged,
            // onChanged: (value) {},
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            menuMaxHeight: 400,
            //  isDense: true,
          ),
        ),
      ],
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

  Widget _buildDisabledDialogTextField(
      String label, TextEditingController controller,
      //Function(String) onChanged,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        // onChanged: onChanged,
        enabled: false,
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {bool isNumber = false, int index = -1, String? field}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: index >= 0 ? ingredients[index][field] ?? '' : '',
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.valueFormat,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            onChanged: (value) {
              if (index >= 0 && field != null) {
                setState(() {
                  ingredients[index][field] = value;
                });
              }
            },
          ),
        ],
      ),
    );
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Column(
              children: [
                // Add Ingredient Button at the top
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Ingredient',
                        style: AppTextStyles.labelBoldFormat,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _showAddIngredientDialog(widget.recipeId);
                        },

                        //_addIngredient,
                      ),
                    ],
                  ),
                ),

                // Ingredient List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      return Card(
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(
                            color: Color.fromRGBO(231, 231, 231, 1),
                            width: 1,
                          ),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            ingredient['name'] ?? 'Ingredient',
                            style: AppTextStyles.labelBoldFormat,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quantity',
                                    style: AppTextStyles.labelFormat,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: TextFormField(
                                          initialValue: ingredients[index]
                                              ["quantity"],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            fillColor: Colors.grey[200],
                                            filled: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 8.0,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Quantity is required';
                                            }
                                            return null;
                                          },
                                          enabled: false,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 210.0,
                                        height: 40,
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          value: ingredients[index]
                                              ['quantity_unit'],
                                          items: massUnits.map((String unit) {
                                            return DropdownMenuItem<String>(
                                              value: unit,
                                              child: Text(unit),
                                            );
                                          }).toList(),
                                          onChanged: null,
                                          validator: (value) {
                                            if (selectedUnit == null) {
                                              return 'Unit is required';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 8.0,
                                            ),
                                          ),
                                          dropdownColor: const Color.fromRGBO(
                                              253, 253, 253, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  buildDisabledTextField(
                                    'Wastage',
                                    '',
                                    initialValue: ingredients[index]["wastage"],
                                  ),
                                  const SizedBox(height: 10),
                                  buildDisabledTextField(
                                    'Cost',
                                    '',
                                    initialValue:
                                        ingredients[index]["cost"].toString(),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      String deleteIngredientId =
                                          ingredients[index]
                                              ["recipe_ingredient_id"];
                                      confirmDelete(deleteIngredientId);
                                    }),
                                    child: const Text(
                                      'Delete Ingredient',
                                      style: TextStyle(
                                        color: Color.fromRGBO(244, 67, 54, 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No Data Available'));
        },
      ),
    );
  }

  Widget buildDisabledTextField(String label, String hint,
//initialValue,
      {required initialValue}) {
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
          const SizedBox(height: 8),
          SizedBox(
            width: 340,
            height: 40,
            child: TextFormField(
              initialValue: initialValue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    costController.dispose();
    wastageController.dispose();
    super.dispose();
  }
}

class EditIngredientsTab extends StatelessWidget {
  final String recipeId;

  const EditIngredientsTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return RecipeTabs(
      initialIndex: 1,
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
