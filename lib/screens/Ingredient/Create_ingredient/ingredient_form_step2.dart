import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';

class IngredientFormStep2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> data;

  IngredientFormStep2({
    required this.formKey,
    required this.data,
    super.key,
  });

  //const IngredientFormStep2({super.key});

  @override
  State<IngredientFormStep2> createState() => _IngredientFormStep2State();
}

class _IngredientFormStep2State extends State<IngredientFormStep2> {
  //final List<Map<String, String>> _measurements = [];
  bool _showMeasurementForm = false;
  String? selectedUnit; // Variable to hold selected unit
  String? selectedWeightUnit;

  void calculateCost() {
    double price = (widget.data['cost'] ?? 0.0).toDouble();
    double weight = (widget.data['weight'] ?? 1.0)
        .toDouble(); // Default to 1 to avoid division by zero
    double quantity =
        (widget.data['quantity'] ?? 1.0).toDouble(); // Default to 1 for safety

    // Apply the formula
    double cost = (price * weight) / quantity;

    setState(() {
      widget.data['measurement_cost'] =
          cost.toStringAsFixed(2); // Round to 2 decimal places
    });
  }

  final List<String> measurmentUnit = [
    'Serving',
    'Box',
    'Bag',
    'Can',
    'Carton',
    'Jar',
    'Punnet',
    'Container',
    'Packet',
    'Roll',
    'Bunch',
    'Bottle',
    'Tin',
    'Tub',
    'Piece',
    'Block',
    'Portion',
    'Dozen',
    'Bucket',
    'Slice',
    'Pinch',
    'Tray',
    'Teaspoon',
    'Tablespoon',
    'Cup'
  ]..sort();
  final List<String> massUnits = [
    'gm',
    'kg',
    'oz',
    'lbs',
    'tonne',
    'ml',
    'cl',
    'dl',
    'L',
    'Pint',
    'Quart',
    'fl oz',
    'gallon',
    'Each',
  ]..sort();

  void calculateWastagePercentage() {
    // Parse the values
    double wastage =
        double.tryParse(widget.data['wastage_quantity']?.toString() ?? '0') ??
            0;
    double totalQuantity =
        double.tryParse(widget.data['weight']?.toString() ?? '1') ??
            1; // Avoid zero

    double wastagePercentage = (wastage / totalQuantity) * 100;

    setState(() {
      widget.data['wastage_percentage'] = wastagePercentage.toStringAsFixed(2);
    });

    print("Wastage Percentage: ${widget.data['wastage_percentage']}");
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child:
          // return
          ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Measurement',
                style: AppTextStyles.labelBoldFormat,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  //_showMeasurementForm = true;
                  setState(() {
                    _showMeasurementForm = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_showMeasurementForm)
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.5, // Center the prompt text
              child: const Center(
                child: Text(
                  'Tap the add icon to enter a measurement.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Add measurement form will be here
          if (_showMeasurementForm) _buildMeasurementForm(),
        ],
      ),
    );
  }

  Widget _buildMeasurementForm() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0), // Adjust radius for roundness
        side: BorderSide(
            color: Colors.grey[300]!, width: 1), // Border color and width
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns all child widgets to the start
          children: [
            _buildQuantityAndUnitFields(),
            const SizedBox(height: 16),
            _buildWeightAndUnitFields(),
            const SizedBox(height: 16),
            buildDisabledCTextField(
              'Cost',
              onSaved: null,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0), // Space between label and fields
        Row(
          children: [
            SizedBox(
              width: 100.0, // Adjust the width as needed
              height: 40,
              child: TextFormField(
                initialValue: widget.data['measurement_quantity']?.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  errorStyle: const TextStyle(height: 0), // Prevent resizing
                ),
                onSaved: (value) {
                  widget.data['measurement_quantity'] =
                      double.tryParse(value ?? '');
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8), // Space between text field and dropdown
            SizedBox(
              width: 210.0,
              height: 40,
              child: DropdownButtonFormField<String>(
                value: selectedUnit,
                isExpanded: true,
                hint: const Text(
                  'Select unit',
                  style: AppTextStyles.hintFormat,
                ),
                items: measurmentUnit.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: SizedBox(
                      width: 150, // Set the width of the dropdown item
                      height: 40,
                      child: Text(unit),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  //selectedUnit = newValue;
                  setState(() {
                    widget.data['measurement_unit'] = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  //isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  errorStyle: const TextStyle(height: 0), // Prevent resizing
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unit is required';
                  }
                  return null;
                },
                // validator: (value) {
                //   return _validateFields(
                //       widget.data['measurement_quantity'], value);
                // },
                dropdownColor: Color.fromRGBO(253, 253, 253, 1),
                menuMaxHeight: 400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightAndUnitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight',
          style: AppTextStyles.labelFormat,
        ),
        const SizedBox(height: 8.0), // Space between label and fields
        Row(
          children: [
            SizedBox(
              width: 100.0, // Adjust the width as needed
              height: 40,
              child: TextFormField(
                initialValue: widget.data['weight']?.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter weight',
                  hintStyle: AppTextStyles.hintFormat,
                  //const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  errorStyle: const TextStyle(height: 0), // Prevent resizing
                ),
                onSaved: (value) {
                  widget.data['weight'] = double.tryParse(value ?? '1') ?? 1;
                  calculateWastagePercentage(); // Recalculate cost when the quantity is saved
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Weight is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    widget.data['weight'] = double.tryParse(value) ?? 1.0;
                    calculateCost(); // Call to recalculate cost
                  });
                },
              ),
            ),
            const SizedBox(width: 10), // Space between text field and dropdown
            SizedBox(
              width:
                  210.0, // Adjust the width as needed to match the text field
              height: 40,

              child: TextFormField(
                initialValue: widget.data['quantity_unit']?.toString(),
                // widget.data['quantity_unit']?.toString(),
                enabled: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  // hintText: 'Enter weight',
                  hintStyle: AppTextStyles.hintFormat,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  // isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  errorStyle: const TextStyle(height: 0), // Prevent resizing
                ),
                onSaved: (value) {
                  widget.data['weight_unit'] = widget.data['quantity_unit'];
                  // Recalculate cost when the quantity is saved
                },
                onChanged: null,
                //enabled: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDisabledCTextField(String label,
//String hint,
      {required Function(String?)? onSaved}) {
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
              key: ValueKey(widget
                  .data['measurement_cost']), // Force rebuild on value change
              initialValue: widget.data['measurement_cost']?.toString() ?? '0',
              decoration: InputDecoration(
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

              enabled: false,
              onSaved: onSaved, // Call the onSaved function when saving
            ),
          ),
        ],
      ),
    );
  }
}
