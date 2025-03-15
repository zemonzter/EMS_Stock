import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(
      Uri.parse('https://api.rmutsv.ac.th/elogin/token/${widget.token}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception(
          'Failed to retrieve user data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            final userData = snapshot.data!;

            // Check for expected keys before accessing
            final expectedKeys = [
              'username',
              'name',
              'email',
              'type',
              'token',
            ];
            for (var key in expectedKeys) {
              if (!userData.containsKey(key)) {
                print('Warning: Key "$key" missing in user data');
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Username: ${userData['username']}'),
                    Text('Name: ${userData['name']}'),
                    Text('Email: ${userData['email']}'),
                    Text('Type: ${userData['type']}'),
                    Text('Token: ${userData['token']}'),
                    // ... Display other user data
                  ],
                ),
              ),
            );
          }

          return const SizedBox(); // Empty state (optional)
        },
      ),
    );
  }
}
