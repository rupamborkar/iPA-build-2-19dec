import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';

Widget buildTextField(
  String label,
  String hint, {
  int maxLines = 1,
  Function(String)? onChanged,
  // required TextInputType keyboardType,
  //required TextEditingController controller
}) {
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
          width: 353, // Fixed width of 353px
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
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

Widget buildDisabledTextField(String label, String hint,
    {required Null Function(dynamic value) onChanged}) {
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
          width: 353, // Fixed width of 353px
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey[300]!, width: 1), // Grey border
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.grey[200], // Grey background color
              filled: true, // To make the fill color visible
            ),
            // TextFormField(
            //   decoration: InputDecoration(
            //     hintText: hint,
            //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            //   ),
            enabled: false,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

Widget buildDropdownField(
  String label,
  List<String> items, {
  required Function(dynamic value) onChanged,
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
        width: 353, // Fixed width of 353px
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
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          // onChanged: (value) {},
          decoration: InputDecoration(
            // hintText: 'Select $label',
            // hintStyle: AppTextStyles.hintFormat,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          //  isDense: true,
          menuMaxHeight: 400,
        ),
      ),
    ],
  );
}

Widget buildRowDisabledTextField(String label, String hint,
    {required Null Function(dynamic value) onChanged}) {
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
          width: 165, // Fixed width of 353px
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey[300]!, width: 1), // Grey border
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.grey[200], // Grey background color
              filled: true,
            ),
            enabled: false,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

Widget buildRowTextField(
  String label,
  String hint, {
  int maxLines = 1,
  Function(String)? onChanged,
}) {
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
          width: 165, // Fixed width of 353px
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
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}
