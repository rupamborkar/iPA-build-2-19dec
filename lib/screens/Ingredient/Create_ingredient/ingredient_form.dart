import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Create_ingredient/step_progress_indicator.dart';
import 'ingredient_form_step1.dart';
import 'ingredient_form_step2.dart';
import 'ingredient_form_step3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientForm extends StatefulWidget {
  final String token;
  const IngredientForm({super.key, required this.token});

  @override
  _IngredientFormState createState() => _IngredientFormState();
}

class _IngredientFormState extends State<IngredientForm> {
  int _currentStep = 0; // Tracks the current step in the form
  final Map<String, dynamic> _ingredientData = {
    "name": null,
    "category": null,
    "supplier_id": null,
    "product_code": null,
    "quantity": null,
    "quantity_unit": null,
    "weight": null,
    "weight_unit": null,
    "measurement_quantity": null,
    "measurement_unit": null,
    "measurement_cost": null,
    "cost": null,
    "price": null,
    "comments": null,
    "wastage_type": null,
    "wastage_percentage": null,
    "wastage_quantity": null,
  };

  final List<GlobalKey<FormState>> _stepKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  void _nextStep() {
    final formKey = _stepKeys[_currentStep];
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        _saveIngredient();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _saveIngredient() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ingredients/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(_ingredientData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient saved successfully!')),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 403) {
        duplicateIngredient(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save ingredient: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void duplicateIngredient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Ingredient with same name already exists'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Ingredient',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Color.fromRGBO(101, 104, 103, 1),
                ),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StepProgressIndicator(currentStep: _currentStep, totalSteps: 3),
            const SizedBox(height: 15),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  IngredientFormStep1(
                    formKey: _stepKeys[0],
                    data: _ingredientData,
                  ),
                  IngredientFormStep2(
                    formKey: _stepKeys[1],
                    data: _ingredientData,
                  ),
                  IngredientFormStep3(
                    formKey: _stepKeys[2],
                    data: _ingredientData,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: AppStyles.elevatedButtonStyle,
                child: Text(
                  _currentStep < 2 ? 'Next' : 'Save',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
