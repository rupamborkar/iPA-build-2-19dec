import 'package:flutter/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/ingredient_tab.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_measurements.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_wastage.dart';

class IngredientEditDetails extends StatefulWidget {
  const IngredientEditDetails({super.key});

  @override
  State<IngredientEditDetails> createState() => _IngredientEditDetailsState();
}

class _IngredientEditDetailsState extends State<IngredientEditDetails> {
  String? selectedUnit;
  final List<String> massUnits = ['kg', 'g', 'lbs', 'oz'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Ingredient Name *', 'Almond'),
                const SizedBox(height: 15),
                buildDropdownField(
                    'Category *', ['Vegetable', 'Fruit', 'Meat', 'Nuts']),
                const SizedBox(height: 15),
                buildDropdownField(
                    'Supplier *', ['Supplier A', 'Supplier B', 'Supplier C']),
                const SizedBox(height: 15),
                _buildTextField('Supplier Product Code', 'e.g. CB12234'),
                const SizedBox(height: 15),
                _buildQuantityAndUnitFields(),
                const SizedBox(height: 15),
                _buildTextField('Tax', '12%'),
                const SizedBox(height: 15),
                _buildTextField('Price', 'Enter a price'),
                const SizedBox(height: 15),
                _buildTextField('Comments', 'Enter the comments', maxLines: 4),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
        Padding(
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
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: const TextStyle(
                color: Color.fromRGBO(150, 152, 151, 1),
                fontSize: 13,
                height: 1.5,
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
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
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

  Widget buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: const TextStyle(
              color: Color.fromRGBO(150, 152, 151, 1),
              fontSize: 13,
              height: 1.5,
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
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {},

            decoration: InputDecoration(
              hintText: 'Select $label',
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
            // decoration: InputDecoration(
            //   hintText: 'Select $label',
            //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            // ),
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
        const SizedBox(height: 8.0),
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
              width: 225.0,
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
}

// Main widget for EditIngredient with IngredientTabs
class IngredientEdit extends StatelessWidget {
  const IngredientEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return IngredientTabs(
      initialIndex: 0,
      tabViews: [
        IngredientEditDetails(), // Content for the 'Details' tab
        IngredientsEditMeasurements(), // Content for the 'Measurements' tab
        IngredientsEditWastage(), // Content for the 'Wastage' tab
      ],
    );
  }
}
