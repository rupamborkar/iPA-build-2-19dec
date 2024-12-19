import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Account/user_profile.dart';
import 'package:flutter_app_login/screens/Bottom_Navbar/home_tab_screen.dart';
import 'package:flutter_app_login/screens/Ingredient/Create_ingredient/ingredient_form.dart';
import 'package:flutter_app_login/screens/Menu/Create_menu/createMenuPage1.dart';
import 'package:flutter_app_login/screens/Recipe/Create_recipe/recipe_create_form.dart';
import 'package:flutter_app_login/screens/Stocktake/Create_stocktake/create_stocktake_page.dart';
import 'package:flutter_app_login/screens/Stocktake/Stocktake_detail/stocktake_screen.dart';
import 'package:flutter_app_login/screens/Supplier/Create_supplier/create_supplier.dart';
import 'package:flutter_app_login/screens/Supplier/Supplier_detail/supplier.dart';

class HomeScreen extends StatefulWidget {
  final String token; // Accept the token as a parameter

  const HomeScreen({super.key, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages; // Declare as late to initialize in initState

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTabScreen(
        token: widget.token,
      ), // Home Tab
      SupplierPage(
        jwtToken: widget.token,
      ), // Supplier Tab
      const Center(child: Text("Create Page")), // Create Tab Placeholder
      StocktakeScreen(
        token: widget.token,
      ), // Stocktake Tab
      //     const Center(child: Text("Profile Page")), // Profile Tab
      UserProfileScreen(
        token: widget.token,
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _showCreateBottomSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetItem(
                'Create Ingredient',
                IngredientForm(
                  token: widget.token,
                )),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 0,
              indent: 10,
              endIndent: 10,
            ),
            _buildBottomSheetItem(
                'Create Recipe',
                RecipeCreateForm(
                  token: widget.token,
                )),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 0,
              indent: 10,
              endIndent: 10,
            ),
            _buildBottomSheetItem(
                'Create Menu',
                CreateMenuPage1(
                  token: widget.token,
                )),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 0,
              indent: 10,
              endIndent: 10,
            ),
            _buildBottomSheetItem(
                'Create Supplier',
                CreateSupplierPage(
                  token: widget.token,
                )),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 0,
              indent: 10,
              endIndent: 10,
            ),
            _buildBottomSheetItem(
                'Create Stocktake',
                CreateStocktakePage(
                  token: widget.token,
                )),
          ],
        );
      },
    );
  }

  Widget _buildBottomSheetItem(String text, Widget destination) {
    return ListTile(
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () async {
        Navigator.pop(context); // Close the bottom sheet
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );

        if (result == true) {
          // Refresh the data or rebuild the UI
          setState(() {
            _selectedIndex = 0; // Ensure Home tab is selected
            _pages[0] =
                HomeTabScreen(token: widget.token); // Reinitialize the page
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'Supplier'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Create'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined), label: 'Stocktake'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(0, 128, 128, 1),
        unselectedItemColor: AppColors.iconColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
