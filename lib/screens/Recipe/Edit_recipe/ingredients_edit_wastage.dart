import 'package:flutter/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Edit_ingredient/ingredient_tab.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_ingredient.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_measurements.dart';

class IngredientsEditWastage extends StatefulWidget {
  const IngredientsEditWastage({super.key});

  @override
  _IngredientsEditWastageState createState() => _IngredientsEditWastageState();
}

class _IngredientsEditWastageState extends State<IngredientsEditWastage> {
  bool _showWastageFields = false;

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
                      'Add Wastage',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: Color.fromRGBO(10, 15, 13, 1)),
                    ),
                    IconButton(
                      icon: Icon(
                        _showWastageFields ? Icons.remove : Icons.add,
                        color: const Color.fromRGBO(101, 104, 103, 1),
                      ),
                      onPressed: () {
                        setState(() {
                          _showWastageFields = !_showWastageFields;
                        });
                      },
                    ),
                  ],
                ),
                if (_showWastageFields)
                  Card(
                    elevation: 0,
                    color: Colors.white.withOpacity(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: Color.fromRGBO(231, 231, 231, 1), width: 1),
                    ),
                    child: Container(
                      width: 353,
                      padding:
                          const EdgeInsets.all(12.0), // Padding as specified
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildDisabledTextField('Quantity Purchased', '1 kg'),
                          const SizedBox(height: 16),
                          _buildTextField('Wastage Type', 'Peel'),
                          const SizedBox(height: 16),
                          _buildTextField('Wastage Quantity', '0.5 kg'),
                          const SizedBox(height: 16),
                          _buildDisabledTextField('Wastage %', '0.02%'),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              // Handle deletion logic here
                            },
                            child: const Text(
                              'Delete Wastage',
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
            width: 329, // Fixed width of 353px
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
            style: const TextStyle(
              color: Color.fromRGBO(150, 152, 151, 1),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 329, // Fixed width of 353px
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
                fillColor: const Color.fromRGBO(
                    231, 231, 231, 1), // Grey background color
                filled: true, // To make the fill color visible
              ),
              enabled: false,
            ),
          )
        ],
      ),
    );
  }
}

// Main widget for EditWastage with IngredientTabs
class EditWastage extends StatelessWidget {
  const EditWastage({super.key});

  @override
  Widget build(BuildContext context) {
    return IngredientTabs(
      initialIndex: 2,
      tabViews: [
        IngredientEditDetails(),
        IngredientsEditMeasurements(),
        IngredientsEditWastage(),
      ],
    );
  }
}
