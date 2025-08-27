import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InvestTokensPage extends StatefulWidget {
  @override
  _InvestTokensPageState createState() => _InvestTokensPageState();
}

class _InvestTokensPageState extends State<InvestTokensPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _txnHashController = TextEditingController();

  String? walletAddress;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWalletAddress();
  }

  Future<void> _fetchWalletAddress() async {
    // Set dummy wallet address or implement wallet connection logic here
    setState(() {
      walletAddress = '0xYourWalletAddress';
    });
  }

  Future<void> _handleInvestTokens() async {
    final amount = _amountController.text.trim();
    final txnHash = _txnHashController.text.trim();

    if (walletAddress == null) {
      _showAlert('Please connect your wallet.');
      return;
    }

    if (amount.isEmpty || txnHash.isEmpty) {
      _showAlert('Please enter both amount and transaction hash.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showAlert('Token not found in local storage.');
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.59.199:5000/user/invest-tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: '{"amount": "$amount", "txnHash": "$txnHash"}',
      );

      if (response.statusCode == 200) {
        _showAlert('Tokens successfully invested!');
      } else {
        _showAlert('Error investing tokens: ${response.body}');
      }
    } catch (e) {
      _showAlert('Error investing tokens: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Investment Status'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
                  Text(
                    "Invest Tokens",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
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
                    onPressed: isLoading ? null : _handleInvestTokens,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700],foregroundColor:Colors.white)
                    ,
                    child: Text(isLoading ? "Processing..." : "Invest Tokens"),
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
