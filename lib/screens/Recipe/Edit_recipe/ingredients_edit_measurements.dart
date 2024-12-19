import 'package:flutter/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/ingredient_tab.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_ingredient.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_wastage.dart';

class IngredientsEditMeasurements extends StatefulWidget {
  const IngredientsEditMeasurements({super.key});

  @override
  _IngredientsEditMeasurementsContentState createState() =>
      _IngredientsEditMeasurementsContentState();
}

class _IngredientsEditMeasurementsContentState
    extends State<IngredientsEditMeasurements> {
  bool _showMeasurementFields = false;
  String? selectedUnit;
  final List<String> massUnits = ['kg', 'g', 'lbs', 'oz'];

  @override
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
                      'Add Measurement',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: Color.fromRGBO(10, 15, 13, 1)),
                    ),
                    IconButton(
                      icon: Icon(
                        _showMeasurementFields ? Icons.remove : Icons.add,
                        color: const Color.fromRGBO(101, 104, 103, 1),
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
                      side: const BorderSide(
                          color: Color.fromRGBO(231, 231, 231, 1), width: 1),
                    ),
                    child: Container(
                      width: 353, // Fixed width
                      padding: const EdgeInsets.all(12.0), // Top padding only
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildQuantityAndUnitFields(),
                          const SizedBox(height: 16),
                          _buildWeightAndUnitFields(),
                          const SizedBox(height: 16),
                          _buildTextField('Cost', '\$200'),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              // Handle deletion logic here
                            },
                            child: const Text(
                              'Delete Measurement',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 128, 128, 1),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color.fromRGBO(253, 253, 253, 1)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qty Purchased',
          style: TextStyle(
            color: Color.fromRGBO(150, 152, 151, 1),
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 40,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '1',
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(10, 15, 13, 1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 180.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                value: selectedUnit,
                hint: const Text(
                  'bag',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
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
                validator: (value) {
                  if (selectedUnit == null) {
                    return 'Unit is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
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
        const Text(
          'Weight',
          style: TextStyle(
            color: Color.fromRGBO(150, 152, 151, 1),
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 40,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '1',
                  hintStyle: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      color: Color.fromRGBO(10, 15, 13, 1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 180.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                value: selectedUnit,
                hint: const Text(
                  'kg',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromRGBO(150, 152, 151, 1),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 309, // Fixed width of 353px
            height: 40, // Fixed height of 40px
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(10, 15, 13, 1)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      const BorderSide(width: 1.0, style: BorderStyle.solid),
                ),
              ),
            ),
            // TextFormField(
            //   decoration: InputDecoration(
            //     hintText: hint,
            //     border:
            //         OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            //   ),
          ),
        ],
      ),
    );
  }
}

// Main widget for EditMeasurements with IngredientTabs
class EditMeasurements extends StatelessWidget {
  const EditMeasurements({super.key});

  @override
  Widget build(BuildContext context) {
    return IngredientTabs(
      initialIndex: 1, // Start with the 'Measurements' tab
      tabViews: [
        IngredientEditDetails(), // Content for the 'Details' tab
        IngredientsEditMeasurements(), // Content for the 'Measurements' tab
        IngredientsEditWastage(), // Content for the 'Wastage' tab
      ],
    );
  }
}
