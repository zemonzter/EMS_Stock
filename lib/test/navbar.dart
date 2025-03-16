import 'package:ems_condb/page/home.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';

class NavbarPage extends StatefulWidget {
  final String? token;
  const NavbarPage({super.key, required this.token});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 0; // Keep track of the selected navbar item
  bool _isNavbarVisible = true; // Control navbar visibility

  // Dummy function to demonstrate navigation.  Replace with your actual page routes.
  void _navigateToPage(int index) {
    // Example using a switch statement:
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(token: widget.token!),
          ),
        );
        print("Navigating to Home Page"); //for checking
        break;
      case 1:
        // Navigator.pushNamed(context, '/dashboard');
        print("Navigating to Dashboard Page");
        break;
      case 2:
        print("Navigating to Manage Withdrawals Page");
        break;
      case 3:
        print("Navigating to Manage Repair Requests Page");
        break;
      case 4:
        print("Logging out");
        break;
      default:
        print("Unknown route");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.grey[200], // Consistent background
        elevation: 0, // Remove shadow under the AppBar
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            setState(() {
              _isNavbarVisible = !_isNavbarVisible;
            });
          },
        ),
      ),
      body: Row(
        children: [
          if (_isNavbarVisible) _buildNavBar(context),
          // Expanded(child: _buildPageContent()), // Content removed
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white, // White navbar
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Admin Technician Section
          Container(
            color: Colors.grey[300], // Slightly darker grey for header
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.black, size: 18.0),
                SizedBox(width: 8.0),
                Text(
                  'User',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          _buildNavItem(Icons.home, 'หน้าหลัก', 0),
          _buildNavItem(Icons.dashboard, 'Dashboard', 1),
          _buildNavItem(Icons.settings, 'จัดการการเบิก', 2),
          _buildNavItem(Icons.handyman, 'จัดการแจ้งซ่อม', 3),
          _buildNavItem(Icons.logout, 'ลงชื่อออก', 4),
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
          setState(() {
            _selectedIndex = index;
          });
          _navigateToPage(index); // Call the navigation function
          // Close the navbar after tapping (optional)
          setState(() {
            _isNavbarVisible = false;
          });
        },
      ),
    );
  }
}
