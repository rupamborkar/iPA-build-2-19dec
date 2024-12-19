import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';

Widget buildTextField(String label, String hint,
    {int maxLines = 1,
    required void Function(dynamic value) onSaved,
    required Null Function(dynamic value) onChanged}) {
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
        SizedBox(
          width: 353,
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
            onSaved: onSaved,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

Widget buildDisabledTextField(String label,
//String hint,
    {required Null Function(dynamic value) onSaved}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelFormat,
          ),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          width: 353,
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.grey[200],
              filled: true,
            ),
            enabled: false,
          ),
        ),
      ],
    ),
  );
}

Widget buildDropdownField(
  String label,
  List<String> items, {
  required Function(String?) onSaved,
  Function(String?)? onChanged,
}) {
  return Column(
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
      SizedBox(
        width: 353,
        height: 40,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          hint: Text(
            'Select $label',
            style: AppTextStyles.hintFormat,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: SizedBox(
                width: 100,
                height: 40,
                child: Text(item),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          onSaved: onSaved,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          dropdownColor: Color.fromRGBO(253, 253, 253, 1),
          menuMaxHeight: 400,
        ),
      ),
    ],
  );
}
