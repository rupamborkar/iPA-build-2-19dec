import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Menu/Create_menu/createMenuPage2.dart';
import 'package:flutter_app_login/screens/Menu/Menu_detail/home_menu.dart';

class CreateMenuPage1 extends StatefulWidget {
  final String token;
  const CreateMenuPage1({super.key, required this.token});

  @override
  _CreateMenuPage1State createState() => _CreateMenuPage1State();
}

class _CreateMenuPage1State extends State<CreateMenuPage1> {
  final TextEditingController menuNameController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController numberOfPeopleController =
      TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  DateTime? selectedDate;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> menuData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Menu',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStepProgressIndicator(0),
            const SizedBox(height: 15),
            const Text(
              'Basic Details',
              style: AppTextStyles.labelBoldFormat,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextFields(
                        'Menu Name *',
                        menuNameController,
                        'Enter name of the menu',
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          setState(() {});
                        },
                        child: AbsorbPointer(
                          child: _buildTextFields(
                            'Menu Date',
                            TextEditingController(
                                text: selectedDate != null
                                    ? selectedDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]
                                    : 'Select date'),
                            'Select date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextFields(
                          'Origin', originController, 'Enter the origin'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRowTextFields(
                              'Selling Price',
                              sellingPriceController,
                              'e.g. 12.00',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildRowTextFields(
                              'Number of People',
                              numberOfPeopleController,
                              'Enter number',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildRowDisabledTextField('Menu Cost', 'N/A'),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildRowDisabledTextField(
                              'Food Cost',
                              'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDisabledTextField('Net Earnings', 'N/A'),
                      const SizedBox(height: 12),
                      _buildTextFields(
                        'Comments',
                        commentsController,
                        'Enter any additional notes',
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 353,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final menuData = {
                      "name": menuNameController.text,
                      "date":
                          selectedDate?.toLocal().toString().split(' ')[0] ??
                              '',
                      "origin": originController.text,
                      "selling_price": sellingPriceController.text,
                      "no_of_people": numberOfPeopleController.text,
                      "comments": commentsController.text,
                    };

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateMenuPage2(
                            menuData: menuData, token: widget.token),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        HomeMenuPage(
                          jwtToken: widget.token,
                        );
                      });
                    }
                  }
                },
                style: AppStyles.elevatedButtonStyle,
                child: const Text(
                  'Next',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStepProgressIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildCircle(0, currentStep),
        buildLine(),
        buildCircle(1, currentStep),
      ],
    );
  }

  Widget buildCircle(int step, int currentStep) {
    bool isCompleted = currentStep >= step;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted ? const Color.fromRGBO(0, 128, 128, 1) : Colors.white,
        border: Border.all(
            color: isCompleted
                ? const Color.fromRGBO(0, 128, 128, 1)
                : Colors.grey,
            width: 2),
      ),
    );
  }

  Widget buildLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: const Color.fromRGBO(0, 128, 128, 1),
      ),
    );
  }

  Widget _buildTextFields(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
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
            width: 353,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Colors.grey[300]!,
                    )),
              ),
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              validator: (value) {
                if (label.contains('*') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Enter the ${label.replaceAll('*', '').trim()}';
                }
                return null;
              },
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
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromRGBO(240, 237, 237, 1), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: const Color.fromRGBO(231, 231, 231, 1),
                filled: true,
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowTextFields(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
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
            width: 160,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Colors.grey[300]!,
                    )),
              ),
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              validator: (value) {
                if (label.contains('*') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Enter the ${label.replaceAll('*', '').trim()}';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDisabledTextField(String label, String hint) {
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
            width: 160,
            height: 40,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromRGBO(240, 237, 237, 1), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: const Color.fromRGBO(231, 231, 231, 1),
                filled: true,
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
