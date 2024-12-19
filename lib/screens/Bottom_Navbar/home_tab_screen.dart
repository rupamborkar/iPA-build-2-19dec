import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Ingredient/Ingredient_detail/home_ingredient.dart';
import 'package:flutter_app_login/screens/Menu/Menu_detail/home_menu.dart';
import 'package:flutter_app_login/screens/Recipe/Recipe_detail/home_recipe.dart';

class HomeTabScreen extends StatelessWidget {
  final String token;

  const HomeTabScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Home',
                style: AppTextStyles.heading,
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color.fromRGBO(101, 104, 103, 1),
                ),
                onPressed: () {
                  print("Notifications clicked");
                },
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Color.fromRGBO(0, 128, 128, 1),
            unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
            indicatorColor: Color.fromRGBO(0, 128, 128, 1),
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'Ingredients'),
              Tab(text: 'Recipes'),
              Tab(text: 'Menus'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Ingredients tab
            HomePage(
              jwtToken: token,
            ),
            // Recipes tab
            RecipeHomePage(
              jwtToken: token,
            ),
            // Menus tab
            HomeMenuPage(
              jwtToken: token,
            ),
          ],
        ),
      ),
    );
  }
}
