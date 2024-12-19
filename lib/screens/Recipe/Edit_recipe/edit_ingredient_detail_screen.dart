import 'package:flutter/material.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_ingredient.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_measurements.dart';
import 'package:flutter_app_login/screens/Recipe/Edit_recipe/ingredients_edit_wastage.dart';

class IngredientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ingredientData;

  const IngredientDetailScreen({super.key, required this.ingredientData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color.fromRGBO(0, 128, 128, 1),
            unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
            indicatorColor: Color.fromRGBO(0, 128, 128, 1),
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Measurements'),
              Tab(text: 'Wastage'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            IngredientEditDetails(),
            IngredientsEditMeasurements(),
            IngredientsEditWastage(),
          ],
        ),
      ),
    );
  }
}
