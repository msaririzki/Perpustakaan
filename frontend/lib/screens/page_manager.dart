import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/admin_page.dart';
import 'package:frontend/screens/dashboard_screen.dart';
import 'package:frontend/screens/loans_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;

class PageManager extends StatefulWidget {
  const PageManager({super.key});

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  int _selectedPage = 0;
  bool isAdmin = false;

  final List<String> _pageTitles = [
    'Items Management',
    'Stock Movements',
    'Admin Settings',
    'User Management',
  ];

  final List<Widget> _userPages = [
    const DashboardScreen(),
    const LoansScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _pages = [
    const AdminPage(), // Items Management
    Center(
        child:
            Text('Stock Movements')), // Ganti dengan widget admin yang sesuai
    Center(
        child: Text('Admin Settings')), // Ganti dengan widget admin yang sesuai
    Center(
        child:
            Text('User Management')), // Ganti dengan widget admin yang sesuai
  ];

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      setState(() {
        isAdmin = userData['User']['role'] == 'admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        body: _userPages[_selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage,
          onTap: (index) {
            setState(() {
              _selectedPage = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory), label: 'Items'),
            BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz), label: 'Stock'),
            BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedPage]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Padding(
                  padding: EdgeInsets.only(top: 50, left: 40),
                  child: Text(
                    'Inventory System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ),
            ListTile(
                selected: _selectedPage == 0,
                selectedTileColor: Colors.grey,
                title: Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: _selectedPage == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedPage == 0 ? Colors.black : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedPage = 0);
                }),
            ListTile(
                selected: _selectedPage == 1,
                selectedTileColor: Colors.grey,
                title: Text(
                  'Stock Movement',
                  style: TextStyle(
                    fontWeight: _selectedPage == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedPage == 1 ? Colors.black : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedPage = 1);
                }),
            if (isAdmin)
              ListTile(
                selected: _selectedPage == 2,
                selectedTileColor: Colors.grey,
                title: Text(
                  'Admin Settings',
                  style: TextStyle(
                    fontWeight: _selectedPage == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedPage == 2 ? Colors.black : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedPage = 2);
                },
              ),
            if (isAdmin)
              ListTile(
                selected: _selectedPage == 3,
                selectedTileColor: Colors.grey,
                title: Text(
                  'User Management',
                  style: TextStyle(
                    fontWeight: _selectedPage == 3
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedPage == 3 ? Colors.black : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedPage = 3);
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isAdmin ? _pages[_selectedPage] : _userPages[_selectedPage],
      ),
    );
  }
}
