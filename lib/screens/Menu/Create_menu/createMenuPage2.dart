import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Bottom_Navbar/home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateMenuPage2 extends StatefulWidget {
  final String token;
  final Map<String, dynamic> menuData;
  const CreateMenuPage2(
      {super.key, required this.menuData, required this.token});

  @override
  _CreateMenuPage2State createState() => _CreateMenuPage2State();
}

class _CreateMenuPage2State extends State<CreateMenuPage2> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController quantityUnitController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedUnit; // Variable to hold selected unit
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
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  String? selectedRecipeId;
  final List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> recipeList = [];

  final List<TextEditingController> quantityControllers = [];

  void addRecipeCard() {
    setState(() {
      recipes.add({
        'name': null,
        'quantity': null,
        'quantity_unit': null,
        'base_cost': null,
        'base_selling_price': null,
        'base_food_cost': null,
        'base_net_earnings': null,
      });
      quantityControllers.add(TextEditingController()); // Add a new controller
    });
  }

  void removeRecipeCard(int index) {
    setState(() {
      recipes.removeAt(index);
      quantityControllers[index].dispose();
      quantityControllers.removeAt(index);
    });
  }

  void saveMenu() async {
    final dataToSend = {
      ...widget.menuData,
      "recipes": recipes.where((recipe) {
        return recipe['id'] != null &&
            //recipe['name'] != null &&
            recipe['quantity'] != null &&
            recipe['cost'] != null &&
            recipe['food_cost'] != null &&
            recipe['selling_price'] != null &&
            recipe['net_earnings'] != null;
      }).toList(),
    };
    print(dataToSend);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/menu/add_menu'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json'
        },
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu saved successfully!')),
        );
        //  Navigator.pop(context, true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    token: widget.token,
                  )),
          (Route<dynamic> route) => false,
        );
      } else if (response.statusCode == 403) {
        duplicateMenu(context);
      } else if (response.statusCode == 422) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  ' There are no recipes in menu, Please add recipe to menu')),
        );
      } else {
        throw Exception('Failed to save menu');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void duplicateMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Duplicate Menu'),
          content: const Text('Menu with same name already exists'),
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

      await fetchRecipeList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchRecipeList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/recipes_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipeData = json.decode(response.body);
        setState(() {
          recipeList = recipeData.map((recipe) {
            return {
              'name': recipe['name'],
              'id': recipe['id'],
              'cost': recipe['cost'],
              'selling_price': recipe['selling_price'],
              'food_cost': recipe['food_cost'],
              'net_earnings': recipe['net_earnings'],
            };
          }).toList();

          recipeList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        print(
            'Failed to load recipe data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe data: $e');
    }
  }

  Widget buildRecipeCard(int index) {
    return Card(
      color: const Color.fromRGBO(253, 253, 253, 1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side:
            const BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDropdownField(
              'Recipe Name',
              // Filter out selected recipes in other cards
              recipeList
                  .where((e) =>
                      !recipes.any((r) => r['name'] == e['name']) ||
                      e['name'] == recipes[index]['name'])
                  .map((e) => e['name'] as String)
                  .toList(),
              onChanged: (value) {
                final selectedRecipe = recipeList.firstWhere(
                  (recipe) => recipe['name'] == value,
                );

                setState(() {
                  recipes[index]['name'] = value;
                  recipes[index]['id'] = selectedRecipe['id'];
                  recipes[index]['cost'] = selectedRecipe['cost'];
                  recipes[index]['selling_price'] =
                      selectedRecipe['selling_price'];
                  recipes[index]['food_cost'] = selectedRecipe['food_cost'];
                  recipes[index]['net_earnings'] =
                      selectedRecipe['net_earnings'];
                });
              },
            ),
            const SizedBox(height: 10),
            _buildQuantityAndUnitFields(index),
            const SizedBox(height: 10),
            _buildDisabledTextField(
              'Cost',
              recipes[index]['cost']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 10),
            _buildDisabledTextField(
              'Selling Price',
              recipes[index]['selling_price']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 10),
            _buildDisabledTextField(
              'Food Cost',
              recipes[index]['food_cost']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 10),
            _buildDisabledTextField(
              'Net Earnings',
              recipes[index]['net_earnings']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  removeRecipeCard(index);
                },
                child: const Text(
                  'Delete Recipe',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Menu',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 15,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStepProgressIndicator(1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Recipe',
                  style: AppTextStyles.labelBoldFormat,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: Color.fromRGBO(101, 104, 103, 1),
                  ),
                  onPressed: addRecipeCard,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < recipes.length; i++)
                        buildRecipeCard(i),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 353,
              height: 50,
              //double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Handle save logic here
                    saveMenu();
                  }
                },
                style: AppStyles.elevatedButtonStyle,
                child: const Text(
                  'Save',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStepProgressIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildCircle(0, currentStep),
        buildLine(),
        buildCircle(1, currentStep),
      ],
    );
  }

  Widget buildCircle(int step, int currentStep) {
    bool isCompleted = currentStep >= step;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted ? const Color.fromRGBO(0, 128, 128, 1) : Colors.white,
        border: Border.all(
          color:
              isCompleted ? const Color.fromRGBO(0, 128, 128, 1) : Colors.grey,
          width: 2,
        ),
      ),
    );
  }

  Widget buildLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: const Color.fromRGBO(0, 128, 128, 1),
      ),
    );
  }

  Widget _buildQuantityAndUnitFields(
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity Required',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              width: 345.0,
              height: 40,
              child: TextFormField(
                controller: quantityControllers[index],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                onChanged: (value) {
                  double quantity = double.tryParse(value) ?? 0.0;
                  setState(() {
                    recipes[index]['quantity'] = quantity;

                    // If base values are null, set them as initial values
                    if (recipes[index]['base_cost'] == null) {
                      recipes[index]['base_cost'] = recipes[index]['cost'];
                      recipes[index]['base_selling_price'] =
                          recipes[index]['selling_price'];
                      recipes[index]['base_food_cost'] =
                          recipes[index]['food_cost'];
                      recipes[index]['base_net_earnings'] =
                          recipes[index]['net_earnings'];
                    }

                    // Update the derived fields based on the quantity
                    recipes[index]['cost'] =
                        (recipes[index]['base_cost'] ?? 0.0) * quantity;
                    recipes[index]['selling_price'] =
                        (recipes[index]['base_selling_price'] ?? 0.0) *
                            quantity;
                    recipes[index]['food_cost'] =
                        (recipes[index]['base_food_cost'] ?? 0.0) * quantity;
                    recipes[index]['net_earnings'] =
                        (recipes[index]['base_net_earnings'] ?? 0.0) * quantity;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> items, {
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
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: SizedBox(
                  width: 150, // Set the width of the dropdown item
                  height: 40,
                  child: Text(item),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            // onSaved: onSaved,
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledTextField(String label, String hint) {
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
          const SizedBox(height: 5.0), // Space between the label and text field
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              // controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromRGBO(240, 237, 237, 1), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                //),
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
