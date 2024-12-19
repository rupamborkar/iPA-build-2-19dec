import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter_app_login/screens/Account/application_term.dart';
import 'package:flutter_app_login/screens/Account/change_pass.dart';
import 'package:flutter_app_login/screens/Account/help.dart';
import 'package:flutter_app_login/screens/Account/language_currency.dart';
import 'package:flutter_app_login/screens/Account/manage_user.dart';
import 'package:flutter_app_login/screens/Account/personal_info.dart';
import 'package:flutter_app_login/screens/Account/privacy_notice.dart';
import 'package:flutter_app_login/screens/Login_Screen/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  final String token;

  const UserProfileScreen({super.key, required this.token});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUsersInfo();
  }

  Future<void> _fetchUsersInfo() async {
    try {
      print("Token: ${widget.token}");

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/user/basic_info'), // Ensure correct API endpoint
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          print(userData);
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<bool> _deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/user/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (error) {
      print('Error deleting account: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until data is fetched
    if (userData == null) {
      return Scaffold(
        // appBar: AppBar(
        //   title: Text('Account',
        //       style: TextStyle(
        //           fontSize: 20,
        //           height: 24,
        //           fontWeight: FontWeight.w600,
        //           color: Color.fromRGBO(10, 15, 13, 1))),
        // ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Account',
            style: TextStyle(
                fontSize: 20,
                height: 24,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(10, 15, 13, 1))),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: Color.fromRGBO(101, 104, 103, 1)),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        // padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            Text(userData?['tenant_name'] ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.0),

            Text(userData?['user_name'] ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 2.0),
            Text(
              userData?['email'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20.0),
            _buildLabelField('Profile'),
            SizedBox(height: 12.0),
            _buildListTile(
              title: 'Personal Info',
              icon: Icons.chevron_right,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalInfoScreen(token: widget.token),
                ),
              ),
            ),
            _buildListTile(
              title: 'Change Password',
              icon: Icons.chevron_right,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChangePasswordScreen(token: widget.token),
                ),
              ),
            ),
            _buildListTile(
              title: 'Language & Currency',
              icon: Icons.chevron_right,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageCurrencyScreen(),
                ),
              ),
            ),
            if (userData?['manage_access_role'] == true)
              _buildListTile(
                title: 'Manage Users',
                icon: Icons.chevron_right,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageUsersScreen(token: widget.token),
                  ),
                ),
              )
            else
              _buildDisabledTile('Manage Users'),
            SizedBox(height: 20.0),
            _buildLabelField('Help & Policies'),
            SizedBox(height: 12.0),
            _buildListTile(
              title: 'Help',
              icon: EneftyIcons.lifebuoy_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Help(),
                ),
              ),
            ),
            _buildListTile(
              title: 'Application Terms',
              icon: Icons.description_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppTerms(),
                ),
              ),
            ),
            _buildListTile(
              title: 'Privacy Notice',
              icon: Icons.shield_outlined,
              //Icons.policy_outlined,

              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyNotice(),
                ),
              ),
            ),
            // _buildListTile(
            //   title: 'Delete Account',
            //   icon: Icons.delete_outline,
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => DeleteAcc(),
            //     ),
            //   ),
            // ),
            _buildListTile(
              title: 'Delete Account',
              icon: Icons.chevron_right,
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Account'),
                    content: Text('Do you really want to delete this account?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                );

                if (result == true) {
                  // Call the API to delete the account
                  final success = await _deleteAccount();
                  if (success) {
                    // Navigate to the Login screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            SizedBox(height: 20.0),
            Transform.translate(
              offset: Offset(-155.0, 0.0),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  //textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.buttonColor,
                    //color: Color.fromRGBO(0, 128, 128, 1)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Fine-tune padding
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            Icon(
              icon,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledTile(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
