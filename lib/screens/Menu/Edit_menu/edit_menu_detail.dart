import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Menu/Edit_menu/details_recipe_tab_widget.dart';
import 'package:flutter_app_login/screens/Menu/Edit_menu/edit_recipe_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditMenuDetail extends StatelessWidget {
  final String menuId;

  const EditMenuDetail({
    required this.menuId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<_EditMenuDetailContentState> contentKey =
        GlobalKey<_EditMenuDetailContentState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close,
              size: 20, color: Color.fromRGBO(101, 104, 103, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
      ),
      body: DetailsRecipeTabWidget(
        detailsContent: EditMenuDetailContent(key: contentKey, menuId: menuId),
        recipeContent: EditRecipeDetailsContent(menuId: menuId),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 353,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              contentKey.currentState?.updateMenuDetails();
            },
            style: AppStyles.elevatedButtonStyle,
            child: Text(
              'Update',
              style: AppTextStyles.buttonText,
            ),
          ),
        ),
      ),
    );
  }
}

class EditMenuDetailContent extends StatefulWidget {
  final String menuId;

  const EditMenuDetailContent({super.key, required this.menuId});

  @override
  _EditMenuDetailContentState createState() => _EditMenuDetailContentState();
}

class _EditMenuDetailContentState extends State<EditMenuDetailContent> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final _menuNameController = TextEditingController();
  final _menuDateController = TextEditingController();
  final _originController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  final _menuCostController = TextEditingController();
  final _foodCostController = TextEditingController();
  final _netEarningsController = TextEditingController();
  final _commentsController = TextEditingController();
  DateTime? selectedDate;

  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchMenuDetails();
    } catch (e) {
      print("Error loading token or fetching menu details: $e");
    }
  }

  Future<void> fetchMenuDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/menu/${widget.menuId}'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _menuNameController.text = data['name'] ?? '';
          _menuDateController.text = data['date'] ?? '';
          selectedDate =
              data['date'] != null ? DateTime.tryParse(data['date']) : null;
          _originController.text = data['origin'] ?? '';
          _sellingPriceController.text =
              data['selling_price']?.toString() ?? '';
          _numberOfPeopleController.text =
              data['no_of_people']?.toString() ?? '';
          _menuCostController.text = data['cost']?.toString() ?? '';
          _foodCostController.text = data['food_cost']?.toString() ?? '';
          _netEarningsController.text = data['net_earnings']?.toString() ?? '';
          _commentsController.text = data['comments'] ?? '';
        });
      } else {
        print(
            'Failed to load menu details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu details: $e');
    }
  }

  String _convertToDateFormat(String dateText) {
    try {
      final parts = dateText.split('/');
      final date = DateTime(
        int.parse(parts[2]), // Year
        int.parse(parts[0]), // Month
        int.parse(parts[1]), // Day
      );
      return date.toLocal().toString().split(' ')[0]; // Convert to 'yyyy-MM-dd'
    } catch (e) {
      print('Error parsing date: $e');
      return ''; // Return an empty string or handle the error as needed
    }
  }

  Future<void> updateMenuDetails() async {
    if (_jwtToken == null) return;

    try {
      String menuDate = selectedDate != null
          ? selectedDate!.toLocal().toString().split(' ')[0]
          : _convertToDateFormat(_menuDateController
              .text); // Convert the text to the correct format if no date selected

      final body = json.encode({
        'name': _menuNameController.text,
        "date": menuDate,
        'origin': _originController.text,
        'selling_price': _sellingPriceController.text,
        'no_of_people': _numberOfPeopleController.text,
        'cost': _menuCostController.text,
        'food_cost': _foodCostController.text,
        'net_earnings': _netEarningsController.text,
        'comments': _commentsController.text,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/api/menu/update_menu/${widget.menuId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Menu updated successfully!');

        Navigator.of(context).pop(true);
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu with same name already exists')),
        );
      } else {
        print('Failed to update menu. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating menu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFields('Menu Name *', _menuNameController),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                  _menuDateController.text =
                      pickedDate.toLocal().toString().split(' ')[0];
                });
              }
            },
            child: AbsorbPointer(
              child: _buildDateTextFields(
                'Menu Date',
                _menuDateController,
                'Select date',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextFields('Origin', _originController),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildRowTextFields(
                      'Selling Price', _sellingPriceController)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildRowTextFields(
                      'Number of People', _numberOfPeopleController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildRowDisabledTextField(
                'Menu Cost',
                _menuCostController,
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildRowDisabledTextField(
                'Food Cost',
                _foodCostController,
              )),
            ],
          ),
          const SizedBox(height: 12),
          _buildDisabledTextField(
            'Net Earnings',
            _netEarningsController,
          ),
          const SizedBox(height: 12),
          _buildTextFields('Comments', _commentsController, maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildTextFields(String label, TextEditingController controller,
      {bool isDisabled = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 353,
            height: maxLines > 1 ? null : 40,
            child: TextFormField(
              controller: controller,
              enabled: !isDisabled,
              maxLines: maxLines,
              decoration: InputDecoration(
                //hintText: 'Enter $label',
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(width: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTextFields(
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
                hintStyle: AppTextStyles.valueFormat,
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

  Widget _buildRowTextFields(String label, TextEditingController controller,
      {bool isDisabled = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 160,
            height: maxLines > 1 ? null : 40,
            child: TextFormField(
              controller: controller,
              enabled: !isDisabled,
              maxLines: maxLines,
              decoration: InputDecoration(
                //hintText: 'Enter $label',
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(width: 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTextField(
      String label, TextEditingController controller) {
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
          const SizedBox(height: 5.0), // Space between the label and text field
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                // hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                //const TextStyle(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromRGBO(240, 237, 237, 1),
                      width: 1), // Grey border
                  borderRadius: BorderRadius.circular(10),
                ),
                //),
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

  Widget _buildRowDisabledTextField(
      String label, TextEditingController controller) {
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
          const SizedBox(height: 5.0), // Space between the label and text field
          SizedBox(
            width: 160,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                // hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                //const TextStyle(color: Colors.grey),
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
