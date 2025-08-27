import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BuyTokensPage extends StatefulWidget {
  @override
  _BuyTokensPageState createState() => _BuyTokensPageState();
}

class _BuyTokensPageState extends State<BuyTokensPage> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _txnHashController = TextEditingController();

  bool _loading = false;

  Future<void> buyTokens() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter the amount")));
      return;
    }

    setState(() => _loading = true);

    try {
      // Send the request to the backend to buy tokens
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
      final response = await http.post(
        Uri.parse("http://192.168.59.199:5000/user/buy-tokens"),
         headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json', // ✅ This line is important
  },
  body: jsonEncode({
    'amount': _amountController.text,
    'txnHash': _txnHashController.text, // Also send txnHash if needed
  }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction successful")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction failed")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction failed")));
    } finally {
      setState(() => _loading = false);
    }
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
                  Text("Buy Tokens", style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
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
                    onPressed: _loading ? null : buyTokens,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text(_loading ? "Processing..." : "Buy Tokens"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
