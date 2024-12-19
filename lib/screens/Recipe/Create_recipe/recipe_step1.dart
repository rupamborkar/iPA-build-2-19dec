import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Recipe/Create_recipe/widgets.dart';

class RecipeStep1 extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const RecipeStep1({super.key, required this.recipeData});

  @override
  State<RecipeStep1> createState() => _RecipeStep1State();
}

class _RecipeStep1State extends State<RecipeStep1> {
  bool _useAsIngredient = false;
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

  final List<String> RecipeCategory = [
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
    'Ferments/Preserved',
    'Pizza',
    'Other'
  ]..sort();
  final List<String> tagList = [
    'Contains Nuts',
    'Dairy free',
    'Gluten free',
    'Sugar free',
    'Seafood',
    'Vegan',
    'Vegetarian',
    'Non-Vegetarian'
  ]..sort();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Fixed header at the top
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            alignment: Alignment.centerLeft, // Align text to the left
            child: const Text(
              'Basic Details',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          // Scrollable form fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(
                    'Recipe Name *',
                    'Enter the name of the recipe',
                    onChanged: (value) => widget.recipeData['name'] = value,
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField(
                    'Category',
                    RecipeCategory,
                    onChanged: (value) => widget.recipeData['category'] = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 200,
                        ),
                        child: buildTextField(
                          'Origin',
                          'Enter the origin',
                          onChanged: (value) =>
                              widget.recipeData['origin'] = value,
                        ),
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
                                  color: Color.fromRGBO(150, 152, 151, 1)),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 40,
                              child: ToggleButtons(
                                isSelected: [
                                  _useAsIngredient,
                                  !_useAsIngredient
                                ],
                                onPressed: (int index) {
                                  setState(() {
                                    _useAsIngredient = index == 0;
                                    widget.recipeData['use_as_ingredeint'] =
                                        _useAsIngredient;
                                  });
                                },
                                color: Colors.black,
                                selectedColor:
                                    const Color.fromRGBO(0, 128, 128, 1),
                                fillColor:
                                    const Color.fromRGBO(230, 242, 242, 1),
                                borderRadius: BorderRadius.circular(8.0),
                                borderColor:
                                    const Color.fromRGBO(231, 231, 231, 1),
                                selectedBorderColor:
                                    const Color.fromRGBO(0, 128, 128, 1),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 0.0),
                                    child: Text('Yes'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 0.0),
                                    child: Text('No'),
                                  ),
                                  // SizedBox(
                                  //   width: 121, // Fixed width
                                  //   height: 40,
                                  // ) // Fixed height
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField(
                    'Tags',
                    tagList,
                    onChanged: (value) => widget.recipeData['tag'] = value,
                  ),
                  const SizedBox(height: 16),
                  _buildQuantityAndUnitFields(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: buildRowDisabledTextField(
                        'Cost',
                        'N/A',
                        onChanged: (value) => widget.recipeData['cost'] = value,
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                          child: buildRowTextField(
                        'Tax',
                        'Enter tax%',
                        onChanged: (value) => widget.recipeData['tax'] = value,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: buildRowTextField(
                        'Selling Price',
                        'e.g. 12.00',
                        onChanged: (value) =>
                            widget.recipeData['selling_price'] = value,
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                          child: buildRowDisabledTextField(
                        'Food Cost',
                        'NA',
                        onChanged: (value) =>
                            widget.recipeData['food_cost'] = value,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildDisabledTextField(
                    'Net Earnings',
                    'N/A',
                    onChanged: (value) =>
                        widget.recipeData['net_earnings'] = value,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    'Comments',
                    'Add comments',
                    maxLines: 3,
                    onChanged: (value) => widget.recipeData['comments'] = value,
                  ),
                  const SizedBox(height: 30, width: 30),
                ],
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
        Text(
          'Serving size',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              width: 150.0,
              height: 40,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  // isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                onChanged: (value) {
                  setState(() {
                    widget.recipeData['serving_quantity'] =
                        int.tryParse(value) ?? 1;
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
            const SizedBox(width: 10),
            SizedBox(
              width: 200.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit,
                //widget.recipeData['serving_quantity_unit'],
                //selectedUnit,
                hint: const Text(
                  'Select mass unit',
                  style: AppTextStyles.hintFormat,
                ),
                items: massUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    widget.recipeData['serving_quantity_unit'] = newValue;
                    //selectedUnit = newValue;
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
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: Color.fromRGBO(231, 231, 231, 1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
                menuMaxHeight: 400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
