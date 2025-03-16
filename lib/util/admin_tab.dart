import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/login.dart';
import 'package:ems_condb/mainten_page/admin_maintenance.dart';
import 'package:ems_condb/mt_page/checkout/admin_ap.dart';
import 'package:ems_condb/page/home.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../page/dashboard.dart';
import '../page/user_page.dart';

class TabbedNavbarPage extends StatefulWidget {
  final String token;
  const TabbedNavbarPage({super.key, required this.token});

  @override
  State<TabbedNavbarPage> createState() => _TabbedNavbarPageState();
}

class _TabbedNavbarPageState extends State<TabbedNavbarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0; // Change initial index to 0
  bool _isNavbarVisible = false;
  String userName = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
          _isNavbarVisible = false;
        });
      }
    });
    _getUserDataAndRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        setState(() {
          _tabController.index = 0;

          _selectedIndex = 0;

          _isNavbarVisible = false;
        });

        break;

      case 1:
        setState(() {
          _tabController.index = 1;

          _selectedIndex = 1;

          _isNavbarVisible = false;
        });

        break;

      case 2: //  จัดการการเบิก

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );

        break;

      case 3: // จัดการแจ้งซ่อม

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMaintenance(token: widget.token),
          ),
        );

        break;

      case 4:
        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(builder: (context) => const LoginPage()),

          (route) => false,
        );

        print("Logging out");

        break;

      default:
        print('Unknown route');
    }
  }

  //Gets user data *and* role in one go.  This is the best approach.
  Future<void> _getUserDataAndRole() async {
    try {
      final userData = await _getUserData(); // Get user data.
      setState(() {
        userName =
            userData['name'] ?? 'User'; // Set the userName *immediately*.
      });

      final role = await _fetchUserRole(
        userName,
      ); // Pass userName to _fetchUserRole
      setState(() {
        userRole = role; // Update userRole in the state
      });
    } catch (e) {
      print("Error fetching user data and role: $e");
      setState(() {
        userName = 'User';
        userRole = 'User'; // Default values on error.
      });
    }
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(
      Uri.parse('https://api.rmutsv.ac.th/elogin/token/${widget.token}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception(
        'Failed to retrieve user data. Status code: ${response.statusCode}',
      );
    }
  }

  Future<String> _fetchUserRole(String userName) async {
    // Takes userName as input
    String uri = "${baseUrl}view_user.php";
    try {
      var response = await http.get(Uri.parse(uri));
      if (response.statusCode != 200) {
        // Check for HTTP errors *before* decoding.
        return "User"; // Or throw an exception if you prefer.
      }
      final List<dynamic> users = jsonDecode(response.body);

      final user = users.firstWhere(
        (user) => user['user_name'] == userName, // Use the passed-in userName
        orElse: () => null,
      );

      if (user != null) {
        return user['user_role'] ??
            'User'; // Return the role, default to 'User'
      } else {
        return "User"; // User not found, return default role.
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return "User"; // Return default on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            setState(() {
              _isNavbarVisible = !_isNavbarVisible;
            });
          },
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              if (!Responsive.isMobile(context) && _isNavbarVisible)
                _buildNavBar(context), // แสดง Navbar ด้านข้างหากไม่ใช่ mobile
              Expanded(
                // เพิ่ม Expanded ที่นี่
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Center(child: DashboardPage(token: widget.token)),
                      Center(child: HomePage(token: widget.token)),
                      Center(child: UserPage(token: widget.token)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isNavbarVisible && Responsive.isMobile(context))
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildNavBar(context),
            ),
        ],
      ),
      bottomNavigationBar:
          !_isNavbarVisible
              // bottomNavigationBar:
              // !Responsive.isMobile(context) && !_isNavbarVisible
              ? TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard_customize_outlined)),
                  Tab(icon: Icon(Icons.home_outlined)),
                  Tab(icon: Icon(Icons.person_outline)),
                ],
              )
              : null,
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.grey[300],
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.black, size: 18.0),
                SizedBox(width: 8.0),
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(Icons.dashboard_customize_outlined, 'รายงานสรุป', 0),
          _buildNavItem(Icons.home_outlined, 'หน้าหลัก', 1),
          if (userRole == 'Admin' || userRole == 'Officer')
            _buildNavItem(Icons.add_box_outlined, 'จัดการการเบิก', 2),
          if (userRole == 'Admin' || userRole == 'Engineer')
            _buildNavItem(Icons.handyman_outlined, 'รายการซ่อม(ช่างซ่อม)', 3),
          _buildNavItem(Icons.logout_outlined, 'ลงชื่อออก', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    return Container(
      color: _selectedIndex == index ? Colors.grey[200] : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        onTap: () {
          _navigateToPage(index);
        },
      ),
    );
  }
}
