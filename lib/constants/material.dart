import 'package:flutter/material.dart';

const String baseUrl = 'https://4953-45-112-0-219.ngrok-free.app';

class AppColors {
  static const Color backgroundColor = Colors.white;
  static const Color headingColor = Color.fromRGBO(10, 15, 13, 1);
  static const Color labelColor = Color.fromRGBO(150, 152, 151, 1);
  static const Color hintColor = Color.fromRGBO(101, 104, 103, 1);
  static const Color categoryColor = Color.fromRGBO(0, 128, 128, 1);
  static const Color buttonColor = Color.fromRGBO(0, 128, 128, 1);
  static const Color iconColor = Color.fromRGBO(101, 104, 103, 1);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.headingColor,
  );

  static const TextStyle labelFormat = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.labelColor,
  );

  static const TextStyle hintFormat = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w300,
    color: AppColors.hintColor,
  );

  static const TextStyle labelBoldFormat = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    height: 1.2,
    // height: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.headingColor,
  );

  static const TextStyle valueFormat = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w300,
    color: AppColors.headingColor,
  );

  static const TextStyle dateFormat = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: AppColors.labelColor,
  );

  static const TextStyle nameFormat = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 14,
    height: 1.2,
    // height: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.headingColor,
  );

  static const TextStyle categoryFormat = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.categoryColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(253, 253, 253, 1),
  );
}

class AppStyles {
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );
}
