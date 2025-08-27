import 'package:flutter/material.dart';
import 'package:my_flutter_app/screens/analytics.dart';
import 'package:my_flutter_app/screens/block_user.dart';
import 'package:my_flutter_app/screens/contact_page.dart';

// Import your screen pages from the screens folder
import 'screens/home_page.dart';
import 'screens/userdashboard_page.dart';
import 'screens/admindashboard_page.dart';
import 'screens/login_page.dart';
import 'screens/admin_login_page.dart';
import 'screens/sell_token.dart';
import 'screens/buy_token.dart';
import 'screens/invest_token.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Set initial route to home screen
      routes: {
        '/': (context) => HomePage(),
        '/user-dashboard': (context) => UserDashboard(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/login': (context) => LoginPage(),
        '/admin-login': (context) => AdminAuth(),
        '/sell-tokens': (context) => SellTokensScreen(),
        '/buy-tokens': (context) => BuyTokensPage(),
        '/invest-tokens': (context) => InvestTokensPage(),
        '/contact': (context) => ContactUsPage(),
        '/analytics': (context) => AnalyticsPage(), 
        '/block-user': (context) => BlockUserPage(), 
      },
    );
  }
}
