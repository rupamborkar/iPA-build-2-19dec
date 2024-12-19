import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class IngredientForms extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddIngredient;

  const IngredientForms({super.key, required this.onAddIngredient});

  @override
  State<IngredientForms> createState() => _IngredientFormsState();
}

class _IngredientFormsState extends State<IngredientForms> {
  List<GlobalKey<_IngredientCardState>> cardKeys = []; // Manage state keys
  List<Widget> ingredientCards = []; // List to manage dynamic cards
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;

  List<Map<String, dynamic>> addedIngredients = [];

  /// Adds a new IngredientCard to the list after validating existing cards
  void _addNewCard() {
    for (var key in cardKeys) {
      if (key.currentState != null && !key.currentState!.isFilled()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Please fill all fields in the existing cards before adding a new one."),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop adding a new card
      }
    }

    // Add a new card and its key
    final newKey = GlobalKey<_IngredientCardState>();
    setState(() {
      cardKeys.add(newKey);
      ingredientCards.add(IngredientCard(
        key: newKey,
        onDelete: _deleteCard,
        onSubmit: widget.onAddIngredient,
      ));
    });
  }

  /// Deletes a specific card
  void _deleteCard(Key key) {
    setState(() {
      int index = cardKeys.indexWhere((k) => k == key);
      if (index != -1) {
        cardKeys.removeAt(index);
        ingredientCards.removeAt(index);
      }
    });
  }

  /// Call submitIngredient on all cards
  void submitAllCards() {
    for (var key in cardKeys) {
      key.currentState?.submitIngredient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextButton(
            onPressed: _addNewCard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Add Ingredient",
                  style: AppTextStyles.labelBoldFormat,
                ),
                Icon(Icons.add, color: Color.fromRGBO(10, 15, 13, 1)),
              ],
            ),
          ),
        ),

        // Submit All Button
        if (ingredientCards.isNotEmpty)
          if (ingredientCards.isEmpty)
            const Center(
              child: Text(
                "No ingredients added yet. Click 'Add Ingredient' to get started.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

        // List of Ingredient Cards
        ...ingredientCards,
      ],
    );
  }
}

class IngredientCard extends StatefulWidget {
  final void Function(Key key) onDelete;
  final Function(Map<String, dynamic>) onSubmit;

  const IngredientCard({
    super.key,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController wastageController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  List<Map<String, dynamic>> ingredientList = [];
  String? selectedIngredientName;
  String? selectedIngredientId;
  Timer? _debounceTimer;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;

  bool isSubmitted = false; // To avoid duplicate submissions
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

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
    fetchIngredients();

    quantityController.addListener(() {
      _autoSubmitIfValid;
      _updateCost();
      _updateWastage();
    });
    costController.addListener(_autoSubmitIfValid);

    // Add listener for quantity changes
    quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    // Dispose controllers
    quantityController.removeListener(_onQuantityChanged);
    quantityController.dispose();
    unitController.dispose();
    costController.dispose();
    wastageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updateCost() {
    if (selectedIngredientId != null) {
      double quantity = double.tryParse(quantityController.text) ?? 0.0;
      double costPerUnit = ingredientList.firstWhere((ingredient) =>
              ingredient['id'] == selectedIngredientId)['cost_per_unit'] ??
          0.0;

      // Calculate the total cost
      double totalCost = quantity * costPerUnit;

      setState(() {
        costController.text = totalCost.toStringAsFixed(2); // Update cost field
      });
    }
  }

  /// Updates the wastage field based on the quantity entered
  void _updateWastage() {
    if (selectedIngredientId != null) {
      double quantity = double.tryParse(quantityController.text) ?? 0.0;
      double wastagePerUnit = ingredientList.firstWhere((ingredient) =>
              ingredient['id'] == selectedIngredientId)['wastage_per_unit'] ??
          0.0;

      // Calculate the total wastage
      double totalWastage = quantity * wastagePerUnit;

      setState(() {
        wastageController.text =
            totalWastage.toStringAsFixed(2); // Update wastage field
      });
    }
  }

  /// Automatically update both cost and wastage when the quantity changes
  void _onQuantityChanged() {
    _updateCost();
    _updateWastage();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() => _jwtToken = token);
      await fetchIngredients();
      //await fetchIngredientList();
    } catch (e) {
      //log("Error loading token or fetching ingredient details: $e");
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
          ingredientList = data
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
          ingredientList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  /// Checks if all fields are filled
  bool isFilled() {
    return selectedIngredientId != null && quantityController.text.isNotEmpty;
    //&&
    //costController.text.isNotEmpty;
  }

  /// Automatically submits data when all fields are filled
  /// Automatically submits data when all fields are filled
  void _autoSubmitIfValid() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (isFilled()) {
        submitIngredient();
      }
    });
  }

  /// Submits the ingredient data
  void submitIngredient() {
    if (!isFilled()) return; // Do nothing if not all fields are filled

    final newIngredient = {
      'ingredient_id': selectedIngredientId,
      'ingredient_name': selectedIngredientName,
      'quantity': double.tryParse(quantityController.text) ?? 0.0,
      'quantity_unit': unitController.text,
      'wastage': double.tryParse(wastageController.text) ?? 0.0,
      'cost': double.tryParse(costController.text) ?? 0.0,
    };

    widget.onSubmit(newIngredient); // Send the data
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredient Name Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Ingredient Name',
                  style: AppTextStyles.labelFormat,
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: 353, // Fixed width of 353px
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: selectedIngredientName,
                  items: ingredientList
                      .map((ingredient) => DropdownMenuItem<String>(
                            value: ingredient['name'],
                            child: Text(ingredient['name']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedIngredientName = value;
                      final selected = ingredientList.firstWhere(
                        (element) => element['name'] == value,
                      );
                      selectedIngredientId = selected['id'];
                      unitController.text =
                          selected['quantity_unit']; // Fix unit dynamically
                      isSubmitted = false; // Allow resubmission if changed
                    });
                    _autoSubmitIfValid();
                    _updateCost(); // Calculate and display updated cost
                    _updateWastage(); // Calculate and display updated wastage
                  },
                  decoration: InputDecoration(
                    hintText: 'Select Ingredient',
                    hintStyle: AppTextStyles.hintFormat,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),

          _buildQuantityAndUnitFields(),

          SizedBox(
            height: 8,
          ),

          _buildDisabledField("Wastage", "\$0.00", wastageController),
          SizedBox(
            height: 8,
          ),
          _buildDisabledField("Cost", "\$0.00", costController),

          // Delete Button Only
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => widget.onDelete(widget.key!),
              child: const Text(
                "Delete Ingredient",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
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
          'Quantity Required',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              width: 140,
              height: 40,
              child: TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 200,
              height: 40,
              child: TextFormField(
                controller: unitController, // Display fixed unit
                enabled: false, // Disable editing
                decoration: InputDecoration(
                  hintText: 'Unit',
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  fillColor: Colors.grey[200], // Grey out
                  filled: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisabledField(
      String label, String value, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353,
          height: 40,
          child: TextFormField(
            controller: controller,
            //initialValue: value,
            decoration: InputDecoration(
              hintText: value,
              hintStyle: AppTextStyles.hintFormat,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              fillColor: const Color.fromRGBO(231, 231, 231, 1),
              filled: true,
            ),
            style: const TextStyle(color: Colors.grey),
            enabled: false,
          ),
        ),
      ],
    );
  }
}
