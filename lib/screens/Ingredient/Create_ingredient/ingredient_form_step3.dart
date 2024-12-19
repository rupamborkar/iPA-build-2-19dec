import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Create_ingredient/form_fields.dart';

class IngredientFormStep3 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> data;

  IngredientFormStep3({
    required this.formKey,
    required this.data,
    super.key,
  });

  @override
  State<IngredientFormStep3> createState() => _IngredientFormStep3State();
}

class _IngredientFormStep3State extends State<IngredientFormStep3> {
  bool _showWastageForm = false;
  final TextEditingController _wastagePercentageController =
      TextEditingController();

  @override
  void dispose() {
    _wastagePercentageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IngredientFormStep3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data['quantity'] != oldWidget.data['quantity']) {
      setState(() {
        // The UI refreshes automatically since the new quantity is reflected.
      });
    }
  }

  void calculateWastagePercentage() {
    // Parse the values
    double wastage =
        double.tryParse(widget.data['wastage_quantity']?.toString() ?? '0') ??
            0;
    double totalQuantity =
        double.tryParse(widget.data['quantity']?.toString() ?? '1') ?? 1;

    if (totalQuantity > 0) {
      double wastagePercentage = (wastage / totalQuantity) * 100;

      setState(() {
        widget.data['wastage_percentage'] = wastagePercentage;
        _wastagePercentageController.text =
            wastagePercentage.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Wastage',
                style: AppTextStyles.labelBoldFormat,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _showWastageForm = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_showWastageForm)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const Center(
                child: Text(
                  'Tap the add icon to enter wastage details.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_showWastageForm) _buildWastageForm(),
        ],
      ),
    );
  }

  Widget _buildWastageForm() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDisabledQuantTextField(
              'Quantity Purchased',
              onSaved: (value) {
                widget.data['quantity'] = value;
              },
            ),
            const SizedBox(height: 16),
            buildTextField(
              'Wastage Type',
              'e.g. Peel',
              onSaved: (value) {
                widget.data['wastage_type'] = value;
              },
              onChanged: (value) {
                widget.data['wastage_type'] = value;
              },
            ),
            const SizedBox(height: 16),
            buildTextField(
              'Wastage Quantity',
              'Enter wastage quantity',
              onSaved: (value) {
                double wastageValue = double.tryParse(value ?? '0') ?? 0;
                double quantityPurchased = double.tryParse(
                        widget.data['quantity']?.toString() ?? '0') ??
                    0;

                if (wastageValue > quantityPurchased) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Wastage cannot be more than Quantity Purchased ($quantityPurchased)."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  throw Exception("Invalid wastage quantity.");
                }
                widget.data['wastage_quantity'] = wastageValue;
                calculateWastagePercentage();
              },
              onChanged: (value) {
                double wastageValue = double.tryParse(value) ?? 0;
                double quantityPurchased = double.tryParse(
                        widget.data['quantity']?.toString() ?? '0') ??
                    0;

                if (wastageValue > quantityPurchased) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Wastage cannot be more than Quantity Purchased ($quantityPurchased)."),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  setState(() {
                    widget.data['wastage_quantity'] = wastageValue;
                  });
                  calculateWastagePercentage();
                }
              },
            ),
            const SizedBox(height: 16),
            buildDisabledWPTextField(
              'Wastage %',
              controller: _wastagePercentageController,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget buildDisabledQuantTextField(String label,
      {required Null Function(dynamic value) onSaved}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          width: 353,
          height: 40,
          child: TextFormField(
            initialValue: widget.data['quantity'] != null
                ? '${widget.data['quantity']} ${widget.data['quantity_unit'] ?? ''}'
                : '0',
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              fillColor: Colors.grey[200],
              filled: true,
            ),
            enabled: false,
          ),
        ),
      ],
    );
  }

  Widget buildDisabledWPTextField(String label,
      {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          width: 353, // Fixed width of 353px
          height: 40,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              fillColor: Colors.grey[200],
              filled: true,
            ),
            enabled: false,
          ),
        ),
      ],
    );
  }
}
