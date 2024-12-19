import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'details_recipe_tab_widget.dart';
import 'edit_menu_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditRecipeDetails extends StatelessWidget {
  final String menuId;
  const EditRecipeDetails({super.key, required this.menuId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close,
              size: 20, color: Color.fromRGBO(101, 104, 103, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
      ),
      body: DetailsRecipeTabWidget(
        detailsContent: EditMenuDetailContent(
            menuId: menuId), //  Show EditMenuDetail in Details tab
        recipeContent: EditRecipeDetailsContent(menuId: menuId),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Handle update action
          },
          style: AppStyles.elevatedButtonStyle,
          child: Text(
            'Update',
            style: AppTextStyles.buttonText,
          ),
        ),
      ),
    );
  }
}

class EditRecipeDetailsContent extends StatefulWidget {
  final String menuId;
  const EditRecipeDetailsContent({super.key, required this.menuId});

  @override
  _EditRecipeDetailsContentState createState() =>
      _EditRecipeDetailsContentState();
}

class _EditRecipeDetailsContentState extends State<EditRecipeDetailsContent> {
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
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, TextEditingController>> recipeControllers = [];
  List<Map<String, dynamic>> recipeDropdownList = [];

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

      await fetchMenuDetails();
      await fetchRecipeList();
    } catch (e) {
      print("Error loading token or fetching menu details: $e");
    }
  }

  Future<void> fetchMenuDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = List<Map<String, dynamic>>.from(data['recipes'] ?? []);
        });
      } else {
        print(
            'Failed to load menu details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu details: $e');
    }
  }

  Future<void> fetchRecipeList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/recipes_list'),
        // Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipeData = json.decode(response.body);
        setState(() {
          recipeDropdownList = recipeData.map((recipe) {
            return {
              'name': recipe['name'],
              'id': recipe['id'],
              'cost': recipe['cost'],
              'selling_price': recipe['selling_price'],
              'food_cost': recipe['food_cost'],
              'net_earnings': recipe['net_earnings'],
            };
          }).toList();
          recipeDropdownList..sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        print(
            'Failed to load recipe data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe data: $e');
    }
  }

  Future<void> _updateMenuDetails() async {
    if (_jwtToken == null) return;

    final updatedRecipes = recipes.asMap().entries.map((entry) {
      final index = entry.key;
      //final recipe = entry.value;

      return {
        'name': recipeControllers[index]['name']!.text,
        'measurement': recipeControllers[index]['measurement']!.text,
        'cost': recipeControllers[index]['cost']!.text,
        'food_cost': recipeControllers[index]['food_cost']!.text,
        'net_earnings': recipeControllers[index]['net_earnings']!.text,
      };
    }).toList();

    final updatedMenuData = {
      'recipes': updatedRecipes,
      // Add other menu fields here if needed.
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedMenuData),
      );

      if (response.statusCode == 200) {
        print('Menu details updated successfully!');
      } else {
        print(
            'Failed to update menu details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating menu details: $e');
    }
  }

  Future<void> deleteRecipe(String menuRecipeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/menu/${widget.menuId}/$menuRecipeId'),
        headers: {
          'Authorization': 'Bearer ${_jwtToken}', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted successfully')),
        );

        Navigator.of(context).pop(true); // Pass 'true' as a result

        //Navigator.of(scaffoldContext).pop(); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete recipe.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the recipe.')),
      );
    }
  }

  void confirmDelete(String menuRecipeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this recipe?'),
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
                deleteRecipe(menuRecipeId);
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

  void _addRecipe() {
    setState(() {
      recipes.add({
        'name': '',
        'quantity': '',
        'unit': '',
        'cost': '',
        'foodCost': '',
        'netEarnings': ''
      });
    });
  }

  void duplicateRecipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Duplicate Recipe'),
          content: const Text('Recipe with same name already added'),
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

  void _showAddRecipeDialog() {
    String? selectedRecipeId;
    String? quantityPurchasedUnit;

    // Base values for calculations
    double baseCost = 0.0;
    double baseSellingPrice = 0.0;
    double baseFoodCost = 0.0;
    double baseNetEarnings = 0.0;

    // Calculated values for display
    double calculatedCost = 0.0;
    double calculatedSellingPrice = 0.0;
    double calculatedFoodCost = 0.0;
    double calculatedNetEarnings = 0.0;

    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            quantityController.addListener(() {
              final quantity = int.tryParse(quantityController.text) ?? 0;

              setState(() {
                calculatedCost = baseCost * quantity;
                calculatedSellingPrice = baseSellingPrice * quantity;
                calculatedFoodCost = baseFoodCost * quantity;
                calculatedNetEarnings = baseNetEarnings * quantity;
              });
            });

            return AlertDialog(
              title: const Text(
                'Add New Recipe',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recipe Name Dropdown
                    buildDropdownField(
                      'Recipe Name',
                      recipeDropdownList
                          .map((e) => e['name'] as String)
                          .toList(),
                      onChanged: (value) {
                        final selectedRecipe = recipeDropdownList.firstWhere(
                          (recipe) => recipe['name'] == value,
                        );
                        setState(() {
                          selectedRecipeId = selectedRecipe['id'].toString();
                          baseCost = selectedRecipe['cost'] as double;
                          baseSellingPrice =
                              selectedRecipe['selling_price'] as double;
                          baseFoodCost = selectedRecipe['food_cost'] as double;
                          baseNetEarnings =
                              selectedRecipe['net_earnings'] as double;

                          // Reset calculated values
                          calculatedCost = 0.0;
                          calculatedSellingPrice = 0.0;
                          calculatedFoodCost = 0.0;
                          calculatedNetEarnings = 0.0;
                          quantityController.clear(); // Clear quantity field
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),

                    // Quantity Input and Unit Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            color: Color.fromRGBO(150, 152, 151, 1),
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          width: 275,
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
                                color: Color.fromRGBO(150, 153, 151, 1),
                              ),
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
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Calculated Fields
                    _buildDisabledDialogTextField(
                        'Cost', calculatedCost, (_) => calculatedCost),
                    _buildDisabledDialogTextField('Selling Price',
                        calculatedSellingPrice, (_) => calculatedSellingPrice),
                    _buildDisabledDialogTextField('Food Cost',
                        calculatedFoodCost, (_) => calculatedFoodCost),
                    _buildDisabledDialogTextField('Net Earnings',
                        calculatedNetEarnings, (_) => calculatedNetEarnings),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _sendRecipeToBackend(
                      recipeId: selectedRecipeId!,
                      quantity: int.tryParse(quantityController.text) ?? 0,
                      cost: calculatedCost,
                      sellingPrice: calculatedSellingPrice,
                      foodCost: calculatedFoodCost,
                      netEarnings: calculatedNetEarnings,
                    );
                    Navigator.of(context).pop();
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
      },
    );
  }

  Future<void> _sendRecipeToBackend({
    required String recipeId,
    required int quantity,
    // required String quantityUnit,
    required double cost,
    required double sellingPrice,
    required double foodCost,
    required double netEarnings,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/menu/${widget.menuId}/add_recipe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_jwtToken',
        },
        body: json.encode({
          'recipe_id': recipeId,
          'quantity': quantity,
          //  'quantity_unit': quantityUnit,
          'cost': cost,
          'selling_price': sellingPrice,
          'food_cost': foodCost,
          'net_earnings': netEarnings,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe added successfully')));

        Navigator.of(context).pop(true);
      } else if (response.statusCode == 403) {
        duplicateRecipe(context);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Ingredient with same name already exists')),
        // );
      } else {
        print('Failed to add recipe. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending recipe data: $e');
    }
  }

  Widget buildDropdownField(
    String label,
    List<String> items, {
    // required Function(String?) onSaved,
    Function(String?)? onChanged,
  }) {
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
              style: AppTextStyles.valueFormat,
            ),
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
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            menuMaxHeight: 400,
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
      String label, value, Function(String) onChanged,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value.toString(),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        // onChanged: value,
        //onChanged,
        enabled: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Recipe',
                  style: AppTextStyles.labelBoldFormat,
                ),
                IconButton(
                    icon: const Icon(Icons.add), onPressed: _showAddRecipeDialog
                    //_addIngredient,
                    ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Card(
                    color: const Color.fromRGBO(253, 253, 253, 1),
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: const Color.fromRGBO(231, 231, 231, 1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                recipe['name'] ?? 'New Recipe',
                                style: AppTextStyles.labelBoldFormat,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.expand_more,
                                  size: 18,
                                  color: Color.fromRGBO(101, 104, 103, 1),
                                ),
                                onPressed: () {
                                  setState(() {
                                    recipes[index]['expanded'] =
                                        !(recipes[index]['expanded'] ?? false);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (recipes[index]['expanded'] ?? false)
                            Column(
                              children: [
                                _buildQuantityAndUnitFields(index),
                                const SizedBox(height: 10),
                                _buildDisabledTextField(
                                    'Cost', recipes[index]['cost']!.toString()),
                                const SizedBox(height: 10),
                                _buildDisabledTextField(
                                    'Selling Price',
                                    recipes[index]['selling_price']!
                                        .toString()),
                                const SizedBox(height: 15),
                                _buildDisabledTextField('Food Cost',
                                    recipes[index]['food_cost']!.toString()),
                                const SizedBox(height: 15),
                                _buildDisabledTextField('Net Earnings',
                                    recipes[index]['net_earnings']!.toString()),
                              ],
                            ),
                          TextButton(
                            onPressed: () =>
                                confirmDelete(recipes[index]['id']),
                            child: const Text(
                              'Delete Recipe',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(244, 67, 54, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityAndUnitFields(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity',
            style: AppTextStyles.labelFormat,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 120, // Adjust width for alignment
                height: 40,
                child: TextFormField(
                  initialValue: recipes[index]['measurement']?.toString(),
                  //recipes[index]['quantity'],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '20',
                    hintStyle: AppTextStyles.valueFormat,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                  enabled: false,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 190, // Adjust width for alignment
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: recipes[index]['measurement_unit'],
                  // selectedUnit,
                  hint: const Text(
                    'Serving',
                    style: AppTextStyles.valueFormat,
                  ),
                  items: massUnits.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: null,
                  //  (String? newValue) {
                  //   setState(() {
                  //     selectedUnit = newValue;
                  //   });
                  // },
                  validator: (value) {
                    if (selectedUnit == null) {
                      return 'Unit is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                  menuMaxHeight: 400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 329, // Same width for alignment
            height: 40, // Same height for alignment
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      const BorderSide(width: 1.0, style: BorderStyle.solid),
                ),
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
}
