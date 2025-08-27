import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/screens/userdashboard_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Entry Point of the Application
void main() {
  runApp(MyApp());
}

// Root of the Application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      home: LoginPage(),
    );
  }
}

// Login Page Widget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String state = 'Login'; // Toggle between Login and Sign Up
  final _formKey = GlobalKey<FormState>();

  // Controllers for Form Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  final TextEditingController _sponsoredByController = TextEditingController();

  Future<void> storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('✅ Token Stored: $token');
  }

  // Send Request to Backend
  Future<void> sendRequest() async {
  String url = state == 'Login'
      ? 'http://192.168.59.199:5000/auth/login' 
      : 'http://192.168.59.199:5000/auth/register';

  Map<String, String> body = {
    "referralCode": _referralCodeController.text,
    "password": _passwordController.text,
  };

  if (state == 'Sign Up') {
    body["name"] = _nameController.text;
    body["email"] = _emailController.text;
    body["sponsoredBy"] = _sponsoredByController.text;
    body["password"] = _passwordController.text;
    body["referralCode"] = _referralCodeController.text;
  }

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      print("✅ Success: $responseData");

      // ✅ Store token regardless of login or signup
      if (responseData.containsKey('token')) {
        String token = responseData['token'];
        await storeToken(token);
        print("✅ Token after storing: $token");
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${state == "Login" ? "Login" : "Signup"} Successful')),
        );
      }
    } else {
      print("⚠️ Error: ${response.body}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Something went wrong!")),
        );
      }
    }
  } catch (e) {
    print("⚠️ Exception: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Network Error")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[800],
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 4),
               ) ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state == 'Login' ? 'Login' : 'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  // Name Field (Only for Sign Up)
                  if (state == 'Sign Up')
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? "Enter name" : null,
                    ),

                  if (state == 'Sign Up') SizedBox(height: 10),

                  // Email Field (Only for Sign Up)
                  if (state == 'Sign Up')
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? "Enter email" : null,
                    ),

                  SizedBox(height: 10),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter password" : null,
                  ),
                  SizedBox(height: 10),

                  // Sponsored By (Only in Sign Up)
                  if (state == 'Sign Up')
                    TextFormField(
                      controller: _sponsoredByController,
                      decoration: InputDecoration(
                        labelText: 'Referred By',
                        border: OutlineInputBorder(),
                      ),
                    ),

                  if (state == 'Sign Up') SizedBox(height: 10),

                  // Referral Code
                  TextFormField(
                    controller: _referralCodeController,
                    decoration: InputDecoration(
                      labelText: 'Referral Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter referral code" : null,
                  ),

                  SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendRequest();
                      }
                    },
                    child: Text(state == 'Login' ? 'Login' : 'Sign Up'),
                  ),

                  // Toggle Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        state = state == 'Login' ? 'Sign Up' : 'Login';
                      });
                    },
                    child: Text(
                      state == 'Login'
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Login",
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