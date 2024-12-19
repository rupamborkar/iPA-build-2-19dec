import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';

Widget _buildTextFieldWithLabel(String label, String initialValue) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
          // style: const TextStyle(
          //   color: Color.fromRGBO(150, 152, 151, 1),
          //   fontSize: 13,
          //   height: 1.5,
          //   fontWeight: FontWeight.w500,
          // ),
        ),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,
          child: TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDropdownField(String label, List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(
          text: label.replaceAll('*', ''),
          style: AppTextStyles.labelFormat,
          // style: const TextStyle(
          //   color: Color.fromRGBO(150, 152, 151, 1),
          //   fontSize: 13,
          //   height: 1.5,
          //   fontWeight: FontWeight.w500,
          // ),

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
            hintStyle: AppTextStyles.valueFormat,
            // const TextStyle(
            //     fontSize: 13,
            //     height: 1.5,
            //     fontWeight: FontWeight.w300,
            //     color: Color.fromRGBO(10, 15, 13, 1)),
            //const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildDisabledTextField(String label, String hint) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelFormat,
            // style: const TextStyle(
            //   color: Color.fromRGBO(150, 152, 151, 1),
            //   fontSize: 13,
            //   height: 1.5,
            //   fontWeight: FontWeight.w500,
            // ),
          ),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.valueFormat,
              // const TextStyle(
              //     fontSize: 13,
              //     height: 1.5,
              //     fontWeight: FontWeight.w300,
              //     color: Color.fromRGBO(10, 15, 13, 1)),
              //const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: const Color.fromRGBO(231, 231, 231, 1),
                    width: 1), // Grey border
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: const Color.fromRGBO(
                  231, 231, 231, 1), // Grey background color
              filled: true, // To make the fill color visible
            ),
            enabled: false,
          ),
        ),
      ],
    ),
  );
}
