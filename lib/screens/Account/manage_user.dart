import 'package:flutter/material.dart';
import 'package:flutter_app_login/constants/material.dart';
import 'package:flutter_app_login/screens/Account/assign_role.dart';
import 'package:flutter_app_login/screens/Account/edit_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageUsersScreen extends StatefulWidget {
  final String token;

  const ManageUsersScreen({super.key, required this.token});
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late Future<List<Map<String, String>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  Future<List<Map<String, String>>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/user_list'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((user) => {
                //"id": user["id"] as String,
                "name": user["user_name"] as String,
                "role": user["role"] as String,
                "email": user["email"] as String,
              })
          .toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(String email) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/user/delete_user'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,

        //roleController.text,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        _usersFuture = fetchUsers();
      });
    } else {
      throw Exception('Failed to delete user');
    }
  }

  void addUser() async {
    // Navigate to Add User screen and refresh on return
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AssignRolesScreen(token: widget.token)),
    );

    if (result == true) {
      setState(() {
        _usersFuture = fetchUsers();
      });
    }
  }

  void editUser(String email, String role, {required String token}) async {
    // Navigate to Edit User screen and refresh on return
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditUserScreen(
                email: email,
                role: role,
                token: widget.token,
              )),
    );

    if (result == true) {
      setState(() {
        _usersFuture = fetchUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Color.fromRGBO(101, 104, 103, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Manage Users',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(10, 15, 13, 1))),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  'User information',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Expanded(

          Container(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load users'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No users found'));
                }

                final users = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // Adjust size based on content
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(
                      name: user["name"]!,
                      role: user["role"]!,
                      email: user["email"]!,
                      onTap: () => editUser(user["email"]!, user["role"]!,
                          token: widget.token),
                      onDelete: () => deleteUser(user["email"]!),
                    );
                  },
                );
              },
            ),
          ),
          // ),

          Align(
            alignment: Alignment(-1.0, -1.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: addUser,
                  child: Text('Add Users',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.buttonColor,
                        // Color.fromRGBO(0, 128, 128, 1)
                      ))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String role,
    required String email,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Card(
      color: const Color.fromRGBO(253, 253, 253, 1),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:
            BorderSide(color: const Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          role,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IconButton(
            // icon: Icon(Icons.delete, color: Colors.red),
            // onPressed: onDelete,
            // ),
            Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
