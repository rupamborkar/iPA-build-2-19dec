import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Menu/Edit_menu/edit_menu_detail.dart';
import 'package:flutter_app_login/screens/Menu/Edit_menu/edit_recipe_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuDetail extends StatefulWidget {
  final String menuId;
  final String name;

  const MenuDetail({Key? key, required this.menuId, required this.name})
      : super(key: key);

  @override
  _MenuDetailState createState() => _MenuDetailState();
}

class _MenuDetailState extends State<MenuDetail>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late TabController _tabController;
  bool _isExpanded = false; // Track expansion for dropdown
  Map<String, dynamic>? menuData;
  List<dynamic> recipes = []; // Store recipes data
  String? _jwtToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        //final data = json.decode(response.body);

        setState(() {
          menuData = json.decode(response.body);
          recipes = menuData?['recipes'] ?? [];
          isLoading = false;
        });
      } else {
        print(
            'Failed to load menu details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu details: $e');
    }
  }

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
          menuData?['name'] ?? '',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        bottom: TabBar(
          labelColor: Color.fromRGBO(0, 128, 128, 1),
          unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
          indicatorColor: Color.fromRGBO(0, 128, 128, 1),
          labelStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          controller: _tabController,
          tabs: [
            Tab(text: 'Details'),
            Tab(text: 'Recipes'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined,
                color: Color.fromRGBO(101, 104, 103, 1)),
            onPressed: () async {
              if (_tabController.index == 0) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditMenuDetail(menuId: widget.menuId)),
                );
                if (result == true) {
                  setState(() {
                    fetchMenuDetails();
                  });
                }
              } else {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditRecipeDetails(
                            menuId: widget.menuId,
                          )),
                );
                if (result == true) {
                  setState(() {
                    isLoading = true;
                  });
                  await fetchMenuDetails();
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildRecipeTab(),
              ],
            ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Color.fromRGBO(253, 253, 253, 1),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side:
                  BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Menu Name :', menuData?['name'] ?? ''),
                  _buildDetailRow('Menu Date :', menuData?['date'] ?? ''),
                  _buildDetailRow('Selling Price :',
                      '\$${menuData?['selling_price'] ?? '0.00'}'),
                  _buildDetailRow(
                      'Cost :', '\$${menuData?['cost']?.toString() ?? 'N/A'}'),
                  _buildDetailRow('Food Cost :',
                      '\$${menuData?['food_cost']?.toString() ?? 'N/A'}'),
                  _buildDetailRow('Food Cost Percentage:',
                      '${menuData?['food_cost_perc'] ?? 0}%'),
                  _buildDetailRow('Net Earnings :',
                      '\$${menuData?['net_earnings']?.toString() ?? 'N/A'}'),
                  _buildDetailRow('Price Per Person :',
                      '\$${menuData?['price_per_person'] ?? '0.00'}'),
                  _buildDetailRow('Number of People :',
                      '${menuData?['no_of_people'] ?? '0'}'),
                  _buildDetailRow(
                      'Comments :', menuData?['comments'] ?? 'No Comments'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      confirmDelete(); // Show the delete confirmation dialog
                    },
                    child: Text(
                      'Delete Menu',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteMenu(String menuId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/menu/$menuId'), // Update the endpoint if necessary
        headers: {
          'Authorization': 'Bearer $_jwtToken', // Use the JWT token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu deleted successfully')),
        );
        Navigator.of(context).pop(true); // Return to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete menu.')),
        );
      }
    } catch (e) {
      print('Error deleting menu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the menu.')),
      );
    }
  }

  void confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this menu?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Cancel delete
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                deleteMenu(widget.menuId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (result ?? false) {
      // Handle page refresh after successful delete
      fetchMenuDetails();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: AppTextStyles.labelFormat,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: AppTextStyles.valueFormat,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _buildRecipeItem(recipe);
        },
      ),
    );
  }

  Widget _buildRecipeItem(Map<String, dynamic> recipe) {
    return Card(
      color: Color.fromRGBO(253, 253, 253, 1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: ExpansionTile(
        title: Text(recipe['name'] ?? ' ',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13, height: 1.5)),
        trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    'Measurement:', '${recipe['measurement'] ?? '0.00'}'),
                _buildDetailRow('Cost:', '\$${recipe['cost'] ?? '0.00'}'),
                _buildDetailRow(
                    'Selling Price:', '\$${recipe['selling_price'] ?? '0.00'}'),
                _buildDetailRow(
                    'Food Cost:', '\$${recipe['food_cost'] ?? '0'}'),
                _buildDetailRow(
                    'Net Earnings:', '\$${recipe['net_earnings'] ?? '0.00'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
