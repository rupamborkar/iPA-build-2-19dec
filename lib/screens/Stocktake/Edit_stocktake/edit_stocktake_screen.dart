import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Stocktake/Edit_stocktake/stocktake_tab_widget.dart';

class EditStocktakeScreen extends StatelessWidget {
  final String stocktakeId;
  final int ingredientId;

  const EditStocktakeScreen(
      {super.key, required this.stocktakeId, required this.ingredientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              size: 15, color: Color.fromRGBO(101, 104, 103, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StocktakeTabsWidget(
        stocktakeId: stocktakeId,
        ingredientId: ingredientId,
        isEditing: true,
        onSave: () {
          Navigator.of(context).pop(true);
          // Navigator.pop(context);
          print('Updated stocktake details');
        },
      ),
    );
  }
}
