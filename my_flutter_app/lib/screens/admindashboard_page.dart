import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? adminData;
  bool loading = true;
  String? error;
  String? message;

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');

      if (token == null) {
        setState(() {
          error = 'Admin token not found';
          loading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.59.199:5000/admin/admin-dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          adminData = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          error = 'Error fetching data: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching data: $e';
        loading = false;
      });
    }
  }

 Future<void> handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminToken');
    Navigator.pushReplacementNamed(context, '/admin-login');
  }

 Future<void> handleDistributeSalary() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('adminToken');

    final response = await http.post(
      Uri.parse('http://192.168.59.199:5000/user/distribute-salary'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = json.decode(response.body);
    setState(() {
      message = responseData['message'] ?? 'Salary distributed successfully!';
    });

    // 🔁 REFRESH admin data to reflect new token values
    await fetchAdminData();  // <-- Add this line

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          message = null;
        });
      }
    });
  } catch (e) {
    setState(() {
      message = 'Failed to distribute salary: $e';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/mjy12.jpg'), // Your image path
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Main content with transparency
        loading
            ? const Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: CircularProgressIndicator(color: Colors.purple)),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.purple.withOpacity(0.9),
                  title: const Text('Admin Dashboard'),
                  titleTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: fetchAdminData,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                body: error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            error!,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoCard('Admin Name', adminData?['name']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Email', adminData?['email']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Role', adminData?['role']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Referral Code', adminData?['referralCode']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Rank', adminData?['rank']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Personal Deposit', adminData?['personalDeposit']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Direct Users', adminData?['directUsers']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Team Sales', adminData?['teamSales']),
                            const SizedBox(height: 12),
                            _buildInfoCard('Total Tokens', adminData?['tokens']),

                            const SizedBox(height: 20),

                            if (message != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: message!.contains('Failed') ? Colors.red[900] : Colors.green[900],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  message!,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            const SizedBox(height: 20),

                            Wrap(
  alignment: WrapAlignment.center,
  spacing: 12,
  runSpacing: 12,
  children: [
    _buildActionButton(
      'Block User',
      Colors.blue,
      () => Navigator.pushNamed(context, '/block-user'),
    ),
    _buildActionButton(
      'Distribute Salary',
      Colors.green,
      handleDistributeSalary,
    ),
    _buildActionButton(
      'Logout',
      Colors.red,
      handleLogout,
    ),
  ],
),


                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
      ],
    );
  }

  Widget _buildInfoCard(String title, dynamic value) {
    final displayValue = value?.toString() ?? 'N/A';
    return Card(
      color: const Color(0xAA262626), // Semi-transparent
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
