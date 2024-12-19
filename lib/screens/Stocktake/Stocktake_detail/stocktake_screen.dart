//edited the bottom bar //
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Stocktake/Stocktake_detail/inventory_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'stocktake_detail_screen.dart';

class StocktakeScreen extends StatefulWidget {
  final String token;

  const StocktakeScreen({super.key, required this.token});

  @override
  State<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends State<StocktakeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> stocktakes = [];
  List<Map<String, dynamic>> filteredStocktakes = [];

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _fetchStocktakes();
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchStocktakes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stocktake/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          stocktakes = data
              .map((stocktake) => stocktake as Map<String, dynamic>)
              .toList();
          filteredStocktakes = stocktakes;
        });
      } else {
        throw Exception('Failed to load stocktakes');
      }
    } catch (error) {
      print('Error fetching stocktakes: $error');
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredStocktakes = stocktakes.where((stocktake) {
        return stocktake['stocktake_name']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Stocktake',
            style: AppTextStyles.heading,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ],
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
              Tab(text: 'Stocktake'),
              Tab(text: 'Inventory'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: 353,
                          height: 32,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(231, 231, 231, 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search',
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
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: filteredStocktakes.map((stocktake) {
                        return StocktakeCard(
                          id: stocktake['id'] ?? '',
                          stocktakeName:
                              stocktake['stocktake_name'] ?? 'Unknown',
                          lastUpdate: stocktake['last_update'].toString() ?? '',
                          totalItems:
                              stocktake['total_items'].toString() ?? '0',
                          totalValue:
                              stocktake['total_values'].toString() ?? '0',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StocktakeDetailScreen(
                                  stocktakeName:
                                      stocktake['stocktake_name'] ?? 'Unknown',
                                  stocktakeId: stocktake['id'].toString(),
                                ),
                              ),
                            );
                            if (result == true) {
                              setState(() {
                                _fetchStocktakes();
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
            InventoryPage(token: widget.token),
          ],
        ));
  }
}

class StocktakeCard extends StatelessWidget {
  final String id;
  final String stocktakeName;
  final String lastUpdate;
  final String totalItems;
  final String totalValue;
  final VoidCallback onTap;

  const StocktakeCard({
    required this.id,
    required this.stocktakeName,
    required this.lastUpdate,
    required this.totalItems,
    required this.totalValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
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
                stocktakeName,
                style: AppTextStyles.nameFormat,
              ),
              const SizedBox(height: 4),
              Text(
                lastUpdate,
                style: AppTextStyles.dateFormat,
              ),
              const Divider(
                thickness: 1,
                color: Color.fromRGBO(230, 242, 242, 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(totalItems, 'Total Items'),
                  _buildInfoColumn('\$${totalValue}', 'Total Value'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.valueFormat,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
      ],
    );
  }
}
