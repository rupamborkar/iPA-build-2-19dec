import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupplierEditScreen extends StatefulWidget {
  final String supplierId;

  const SupplierEditScreen({super.key, required this.supplierId});

  @override
  _SupplierEditScreenState createState() => _SupplierEditScreenState();
}

class _SupplierEditScreenState extends State<SupplierEditScreen> {
  final double fieldHeight = 50.0; // Set default height for all fields
  final double fieldWidth =
      double.infinity; // Set default width for all fields (full width)

  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage
  Map<String, dynamic>? supplierData;
  String? _jwtToken;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      // Retrieve JWT token from secure storage
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchSupplierDetails();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchSupplierDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/supplier/${widget.supplierId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        supplierData = json.decode(response.body);
        setState(() {
          nameController.text = supplierData?['name'] ?? '';
          locationController.text = supplierData?['location'] ?? '';
          emailController.text = supplierData?['email'] ?? '';
          phoneController.text = supplierData?['phone'] ?? '';
          commentsController.text = supplierData?['comments'] ?? '';
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  Future<void> updateSupplierDetails() async {
    if (_jwtToken == null) return;

    try {
      final Map<String, dynamic> payload = {
        "name": nameController.text,
        "location": locationController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "comments": commentsController.text,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/supplier/${widget.supplierId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Supplier details updated successfully!')),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supplier with same name already exists')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update Supplier: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error updating supplier details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Supplier Name *', nameController),
            _buildTextField('Location', locationController),
            _buildTextField('Email', emailController),
            _buildTextField('Phone', phoneController, isNumber: true),
            _buildTextField('Comments', commentsController, maxLines: 1),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Add update logic here
              updateSupplierDetails();
            },
            style: AppStyles.elevatedButtonStyle,
            // style: ElevatedButton.styleFrom(
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30), // Circular ends
            //   ),
            //   backgroundColor: Color.fromRGBO(0, 128, 128, 1),

            //   //backgroundColor: Colors.teal, // Button color
            //   minimumSize: const Size(double.infinity, 50), // Full-width button
            // ),
            child: const Text(
              'Update',
              style: AppTextStyles.buttonText,
              // style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // Define the reusable _buildTextField widget
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    //String hint,
    {
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
          const SizedBox(height: 16),
          SizedBox(
            width: 353,
            height: 40,
            // height: fieldHeight,
            // width: fieldWidth,
            child: TextFormField(
              controller: controller,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
              decoration: InputDecoration(
                //hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                // border: OutlineInputBorder(
                // borderRadius: BorderRadius.circular(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
