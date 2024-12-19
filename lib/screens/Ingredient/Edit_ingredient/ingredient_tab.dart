import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';

class IngredientTabs extends StatefulWidget {
  final int initialIndex;
  final List<Widget> tabViews;

  IngredientTabs({required this.initialIndex, required this.tabViews});

  @override
  _IngredientTabsState createState() => _IngredientTabsState();
}

class _IngredientTabsState extends State<IngredientTabs> {
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
            icon: Icon(
              Icons.close,
              size: 20,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit',
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
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Measurement'),
              Tab(text: 'Wastage'),
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
