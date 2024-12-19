import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';

class RecipeStep3 extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const RecipeStep3({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to Prepare',
            style: AppTextStyles.labelBoldFormat,
          ),
          const SizedBox(height: 8),
          buildTextField(
            '',
            'Enter the method or preparation',
            maxLines: 8,
            onChanged: (value) => recipeData['method'] = value,
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, String hint,
      {int maxLines = 1, Function(String)? onChanged}) {
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
                      color: Colors.red,
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.hintFormat,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: maxLines,
            validator: (value) {
              if (label.contains('*') &&
                  (value == null || value.trim().isEmpty)) {
                return '${label.replaceAll('*', '').trim()} is required';
              }
              return null;
            },
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
