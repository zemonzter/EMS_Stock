import 'package:ems_condb/page/home.dart';
import 'package:flutter/material.dart';

import '../page/dashboard.dart';
import '../page/user_page.dart';
import '../test/navbar.dart';

class TabMenuPage extends StatefulWidget {
  final String token;
  const TabMenuPage({super.key, required this.token});

  @override
  State<TabMenuPage> createState() => _TabMenuPageState();
}

class _TabMenuPageState extends State<TabMenuPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard_customize_outlined)),
              Tab(icon: Icon(Icons.home_outlined)),
              Tab(icon: Icon(Icons.person_outline)),
            ],
          ),
          body: TabBarView(
            children: [
              // const Center(child: Text('Dashboard')),
              // Center(child: DashboardPage(token: widget.token)),
              Center(child: NavbarPage(token: widget.token)),
              Center(child: HomePage(token: widget.token)),
              Center(child: UserPage(token: widget.token)),
            ],
          ),
        ),
      ),
    );
  }
}
