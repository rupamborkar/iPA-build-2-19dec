import 'package:flutter/material.dart';

class DetailsRecipeTabWidget extends StatelessWidget {
  final Widget detailsContent;
  final Widget recipeContent;

  const DetailsRecipeTabWidget({
    Key? key,
    required this.detailsContent,
    required this.recipeContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Color.fromRGBO(0, 128, 128, 1),
            unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
            indicatorColor: Color.fromRGBO(0, 128, 128, 1),
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Recipes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                detailsContent,
                recipeContent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
