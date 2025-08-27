import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.59.199:5000/user/get-details'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            user = data['user'];
          });
        } else {
          print('Failed to fetch user data');
        }
      } else {
        print('Server error: \${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user details: \$error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        backgroundColor: Colors.purple[800],
        titleTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mjy12.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(16.0),
                children: user != null
                    ? [
                        for (var item in [
                          {'title': 'Referral Code', 'value': user!['referralCode'] ?? 'N/A'},
                          {'title': 'People Referred', 'value': user!['directUsers']?.toString() ?? '0'},
                          {'title': 'Total Tokens', 'value': user!['tokens']?.toString() ?? '0'},
                          {'title': 'Token Invested', 'value': user!['investedTokens']?.toString() ?? '0'},
                          {'title': 'Rank', 'value': user!['rank'] ?? 'Unranked'},
                          {'title': 'Personal Deposit', 'value': '\$${user!['personalDeposit'] ?? '0'}'},
                          {'title': 'Rewards', 'value': user!['rewards']?.length.toString() ?? '0'},
                          {'title': 'Team Sales', 'value': '\$${user!['tokens'] ?? '0'}'},
                          {'title': 'Last Activity', 'value': user!['lastActivity'] ?? 'N/A'},
                        ])
                          _buildInfoCard(item['title']!, item['value']!)
                      ]
                    : [],
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple[800],
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('Buy', '/buy-tokens'),
              _buildActionButton('Sell', '/sell-tokens'),
              _buildActionButton('Invest', '/invest-tokens'),
              IconButton(
                onPressed: handleLogout,
                icon: Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildActionButton(String label, String route) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, route).then((_) {
        // Refresh dashboard data after returning
        fetchUserDetails();
      });
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(label),
  );
}

}
