import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BlockUserPage extends StatefulWidget {
  @override
  _BlockUserPageState createState() => _BlockUserPageState();
}

class _BlockUserPageState extends State<BlockUserPage> {
  final TextEditingController emailController = TextEditingController();
  String? status; // "true" or "false"
  String message = "";
  bool loading = false;

  Future<void> handleSubmit() async {
    final email = emailController.text.trim();
    final adminToken = await _getAdminToken();

    if (email.isEmpty || status == null || status!.isEmpty) {
      setState(() => message = "❌ All fields are required!");
      return;
    }

    setState(() {
      loading = true;
      message = "";
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.59.199:5000/admin/block'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
        body: jsonEncode({
          'email': email,
          'status': status == "true",
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        message = data['message'] ?? "✅ User block status updated successfully!";
        loading = false;
      });
    } catch (e) {
      setState(() {
        message = "❌ Failed to update user status.";
        loading = false;
      });
      print('Error: $e');
    }
  }

  // Replace this with your method to get admin token, e.g., from SharedPreferences


Future<String?> _getAdminToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('adminToken'); // returns null if not found
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            width: 350,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Block User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),

                // Email input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Enter user email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Status dropdown
                DropdownButtonFormField<String>(
                  value: status,
                  hint: Text('Select Status'),
                  items: [
                    DropdownMenuItem(value: "true", child: Text('Block')),
                    DropdownMenuItem(value: "false", child: Text('Unblock')),
                  ],
                  onChanged: (val) => setState(() => status = val),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : handleSubmit,
                    child: loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: message.startsWith("❌") ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
