import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Recipe/Create_recipe/recipe_step2.dart';
import 'package:flutter_app_login/screens/Recipe/Create_recipe/step_indicator.dart';
import 'recipe_step1.dart';
import 'recipe_step3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeCreateForm extends StatefulWidget {
  final String token;
  const RecipeCreateForm({super.key, required this.token});

  @override
  _RecipeCreateFormState createState() => _RecipeCreateFormState();
}

class _RecipeCreateFormState extends State<RecipeCreateForm> {
  final Map<String, dynamic> recipeData = {
    "name": "",
    "category": "",
    "origin": "",
    "use_as_ingredeint": '',
    "tag": '',
    "serving_quantity": 0,
    "serving_quantity_unit": "",
    "cost": 0.0,
    "tax": 0.0,
    "selling_price": 0.0,
    "food_cost": 0.0,
    "net_earnings": 0.0,
    "comments": "",
    "method": "",
    "ingredient": [],
  };

  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> saveRecipe() async {
    if (_currentStep < 2) {
      _nextStep();
    } else {
      final url = Uri.parse('$baseUrl/api/recipes/add_recipe');
      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            "Content-Type": "application/json",
          },
          body: jsonEncode(recipeData),
        );
        print(recipeData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe saved successfully!')),
          );

          Navigator.pop(context, true);
        } else if (response.statusCode == 403) {
          duplicateRecipe(context);
        } else {
          throw Exception('Failed to save recipe');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void updateIngredients(List<dynamic> ingredients) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          recipeData["ingredient"] = ingredients;
        });
      }
    });
  }

  List<Widget> steps() {
    return [
      RecipeStep1(recipeData: recipeData),
      // ignore: avoid_types_as_parameter_names
      RecipeStep2(
        recipeData: recipeData,
        onIngredientsChange: updateIngredients,
      ),
      RecipeStep3(recipeData: recipeData),
    ];
  }

  void duplicateRecipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Recipe with same name already exists'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Recipe',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 15),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          StepIndicator(currentStep: _currentStep),
          Expanded(
            child: steps()[_currentStep],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    _nextStep();
                  } else {
                    saveRecipe();
                  }
                },
                style: AppStyles.elevatedButtonStyle,
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: const Color.fromRGBO(0, 128, 128, 1),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(30),
                //   ),
                //   padding: const EdgeInsets.symmetric(vertical: 16),
                // ),
                child: Text(
                  _currentStep < 2 ? 'Next' : 'Save',
                  // style: const TextStyle(fontSize: 18, color: Colors.white),
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
