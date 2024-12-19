import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';

class RecipeTabs extends StatefulWidget {
  final int initialIndex;
  final List<Widget> tabViews;

  const RecipeTabs(
      {super.key, required this.initialIndex, required this.tabViews});

  @override
  _RecipeTabsState createState() => _RecipeTabsState();
}

class _RecipeTabsState extends State<RecipeTabs> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _currentTabIndex,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Edit',
            style: AppTextStyles.heading,
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.teal,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Ingredient'),
              Tab(text: 'Method'),
            ],
          ),
        ),
        body: TabBarView(
          children: widget.tabViews,
        ),
      ),
    );
  }
}












// import 'package:flutter/material.dart';
// import 'package:flutterfoodapp/edit_models/recipe_home_pages/edit_ingredient_recipe.dart';
// import 'package:flutterfoodapp/edit_models/recipe_home_pages/edit_recipe_details.dart';
// // import 'edit_details.dart';
// // import 'edit_ingredient.dart';
// import 'edit_method.dart';

// class EditTabs extends StatelessWidget {
//   const EditTabs({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Edit Recipe'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Details'),
//               Tab(text: 'Ingredient'),
//               Tab(text: 'Method'),
//             ],
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             RecipeEdit(), // Page for editing recipe details
//             EditIngredientDetails(), // Page for editing ingredients
//             EditMethod(), // Page for editing the preparation method
//           ],
//         ),
//       ),
//     );
//   }
// }
