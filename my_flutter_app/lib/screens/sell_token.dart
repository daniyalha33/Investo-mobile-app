import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SellTokensScreen extends StatefulWidget {
  const SellTokensScreen({super.key});

  @override
  State<SellTokensScreen> createState() => _SellTokensScreenState();
}

class _SellTokensScreenState extends State<SellTokensScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _txnHashController = TextEditingController();

  bool _loading = false;

  Future<void> sellTokens() async {
    final input = _tokenController.text.trim();
    final txnHash = _txnHashController.text.trim();

    if (input.isEmpty || double.tryParse(input) == null || txnHash.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Enter valid amount and transaction hash")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse("http://192.168.59.199:5000/user/sell-tokens"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': input,
          'txnHash': txnHash,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Tokens sold successfully")),
        );
        _tokenController.clear();
        _txnHashController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Backend error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Request failed: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _txnHashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.grey.shade900,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Sell Tokens", style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _tokenController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter Token Amount",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _txnHashController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter Transaction Hash",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : sellTokens,
                    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.redAccent,
    foregroundColor: Colors.white, // 👈 sets the text/icon color to white
  ),
                    child: Text(_loading ? "Processing..." : "Sell Tokens"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
