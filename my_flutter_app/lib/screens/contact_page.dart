import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _queryController = TextEditingController();
  String? _response;
  bool _loading = false;

  Future<void> _sendQuery() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter your query')));
      return;
    }

    setState(() {
      _loading = true;
      _response = null;
    });

    try {
      final res = await http.post(
        Uri.parse('http://192.168.59.199:5000/user/query-gemini'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _response = data['response']; // Assumes backend returns { response: "..." }
        });
      } else {
        setState(() {
          _response = "Error from server: ${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Error occurred: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Contact Us"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            // Wrap the Column with SingleChildScrollView
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Ask a Question",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _queryController,
                    maxLines: 3,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter your query",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _sendQuery,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple,foregroundColor: Colors.white),
                    child: Text(_loading ? "Sending..." : "Send"),
                  ),
                  const SizedBox(height: 20),
                  if (_response != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _response!,
                        style: TextStyle(color: Colors.white),
                      ),
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
