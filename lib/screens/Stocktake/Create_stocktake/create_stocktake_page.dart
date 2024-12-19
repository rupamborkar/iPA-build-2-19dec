import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Stocktake/Create_stocktake/stocktake_ingredient_page2.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';

class CreateStocktakePage extends StatefulWidget {
  final String token;
  const CreateStocktakePage({super.key, required this.token});

  @override
  _CreateStocktakePageState createState() => _CreateStocktakePageState();
}

class _CreateStocktakePageState extends State<CreateStocktakePage> {
  int currentStep = 1;
  bool showIngredientForm = false;
  String? selectedUnit;

  final TextEditingController stocktakeNameController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  List<Map<String, dynamic>> ingredients = [];

  void nextStep() {
    setState(() {
      currentStep = 2;
    });
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> saveStocktake() async {
    final stocktakeData = {
      "stocktake_name": stocktakeNameController.text,
      "origin": originController.text,
      "comments": commentsController.text,
      // "ingredients": ingredients,

      "ingredients": ingredients.map((ingredient) {
        return {
          "id": ingredient['ingredient_id'],
          "quantity": ingredient['quantity'],
          "quantity_unit": ingredient['quantity_unit'],
          "cost": ingredient['cost'],
          "wastage": ingredient['wastage'],
        };
      }).toList(),
    };
    log('check_ingredients $ingredients');
    log('check_stocktakeData $stocktakeData');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/stocktake/add_stocktake'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(stocktakeData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stocktake saved successfully!')),
        );
        Navigator.pop(context, true);
        // Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save stocktake.')),
        );
      }
    } catch (e) {
      log('check_Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void toggleIngredientForm() {
    setState(() {
      showIngredientForm = !showIngredientForm;
    });
  }

  void addIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      //ingredients.add(ingredient);
      ingredients.add({
        'ingredient_id': ingredient['ingredient_id'],
        'quantity': ingredient['quantity'],
        'quantity_unit': ingredient['quantity_unit'],
        'cost': ingredient['cost'],
        'wastage': ingredient['wastage'],
      });
    });

    log('checkhere $ingredients');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Center(
          child: Text(
            'Create Stocktake',
            style: AppTextStyles.heading,
          ),
        ),
        leading: currentStep == 2
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 15),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color.fromRGBO(10, 15, 13, 8)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildStepIndicator(),
            const SizedBox(height: 16),
            currentStep == 1 ? buildStep1() : buildStep2(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: currentStep < 2 ? nextStep : saveStocktake,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(0, 128, 128, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              currentStep < 2 ? 'Next' : 'Save',
              style: const TextStyle(
                  fontSize: 18, color: Color.fromRGBO(231, 231, 231, 1)),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Details ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(10, 15, 13, 1),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField("Stocktake Name *", "October 2024",
            controller: stocktakeNameController),
        _buildTextField("Origin", "Enter the origin",
            controller: originController),
        const SizedBox(height: 8),
        _buildDisabledField("Total Items", "0"),
        const SizedBox(height: 10),
        _buildDisabledField("Total Value", "N/A"),
        const SizedBox(height: 8),
        _buildTextField("Comments", "Add comments",
            controller: commentsController),
      ],
    );
  }

  Widget buildStep2() {
    return IngredientForms(
      onAddIngredient: addIngredient,
    );
  }

  Widget buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCircle(1),
        buildLine(),
        buildCircle(2),
      ],
    );
  }

  Widget buildCircle(int step) {
    bool isCompleted = currentStep >= step;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Colors.teal : Colors.white,
        border: Border.all(
            color: isCompleted ? Colors.teal : Colors.grey, width: 2),
      ),
    );
  }

  Widget buildLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: currentStep >= 2 ? Colors.teal : Colors.grey[300],
      ),
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 40,
          width: 353,
          child: TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              hintText: value,
              hintStyle: AppTextStyles.hintFormat,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                // borderSide:
                //     BorderSide(color: Color.fromRGBO(231, 231, 231, 1))
              ),
              fillColor: const Color.fromRGBO(231, 231, 231, 1),
              filled: true,
            ),
            style: const TextStyle(color: Colors.grey),
            enabled: false,
          ),
        )
      ],
    );
  }

  Widget _buildTextField(String label, String placeholder,
      {TextEditingController? controller,
      int maxLines = 1,
      bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
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
                      color: Color.fromRGBO(244, 67, 54, 1),
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 40,
            width: 353,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        width: 1.0,
                        style: BorderStyle.solid,
                        color: Color.fromRGBO(231, 231, 231, 1)),
                  )),
              maxLines: maxLines,
              enabled: enabled,
              style: TextStyle(color: enabled ? Colors.black : Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
