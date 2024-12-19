import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Menu/Menu_detail/menu_detail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeMenuPage extends StatefulWidget {
  final String jwtToken;
  const HomeMenuPage({
    Key? key,
    required this.jwtToken,
  }) : super(key: key);

  @override
  _HomeMenuPageState createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> menus = [];
  List<Map<String, dynamic>> filteredMenus = [];

  @override
  void initState() {
    super.initState();
    _fetchMenus();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchMenus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/menu/'),
        headers: {
          'Authorization':
              'Bearer ${widget.jwtToken}', // Include JWT token here
        },
      );

      print('Requesting ingredients from: $baseUrl/api/menus');
      print('Headers: ${{
        'Authorization': 'Bearer ${widget.jwtToken}',
      }}');
      print('Response body: ${response.body}'); // Debugging print statement
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          menus = data.map((menu) => menu as Map<String, dynamic>).toList();
          filteredMenus = menus;
        });
      } else {
        throw Exception('Failed to load menus');
      }
    } catch (error) {
      print('Error fetching menus: $error');
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredMenus = menus.where((menu) {
        return menu['name']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Search bar
                Expanded(
                  child: Container(
                    height: 32,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search for Menu',
                                hintStyle: AppTextStyles.hintFormat,
                                prefixIcon: Icon(
                                  EneftyIcons.search_normal_2_outline,
                                  size: 20,
                                  color: Color.fromRGBO(101, 104, 103, 1),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(231, 231, 231, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, size: 18),
                    onPressed: () {
                      // Handle filter action
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: filteredMenus.map((menu) {
                  return MenuCard(
                    id: menu['id'],
                    name: menu['name'] ?? 'Unknown',
                    date: menu['date'] ?? '',
                    cost: menu['cost']?.toString() ?? 'N/A',
                    price: menu['selling_price']?.toString() ?? 'N/A',
                    earnings: menu['net_earnings']?.toString() ?? 'N/A',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuDetail(
                            menuId: menu['id'],
                            name: menu['name'] ?? 'Unknown',
                          ),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          _fetchMenus();
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String id;
  final String name;
  final String date;
  final String cost;
  final String price;
  final String earnings;
  final VoidCallback onTap;

  const MenuCard({
    required this.id,
    required this.name,
    required this.date,
    required this.cost,
    required this.price,
    required this.earnings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color.fromRGBO(253, 253, 253, 1),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.nameFormat,
              ),
              SizedBox(height: 4),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: AppTextStyles.dateFormat,
                ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Color.fromRGBO(230, 242, 242, 1)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('\$${cost}', 'Cost'),
                  _buildInfoColumn('\$${price}', 'Selling Price'),
                  // _buildInfoColumn(earnings, 'Net Earnings',
                  //     earnings: earnings),
                  _buildNetEarnInfoColumn(earnings: earnings, 'Net Earnings'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          value,
          style: AppTextStyles.valueFormat,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
      ]),
    );
  }

  Widget _buildNetEarnInfoColumn(String label, {String? earnings}) {
    // Color logic for earnings
    Color earningsColor = earnings != null
        ? double.tryParse(earnings) != null && double.tryParse(earnings)! > 0
            ? Color.fromRGBO(76, 175, 80, 1)
            : Color.fromRGBO(222, 61, 49, 1)
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (earnings != null)
          Text(
            '\$${earnings}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w300,
              color: earningsColor, // Apply the color for net earnings
            ),
          ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
      ]),
    );
  }
}
