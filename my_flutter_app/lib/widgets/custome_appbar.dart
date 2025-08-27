import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize {
    // Dynamically adjust height based on screen size
    final screenWidth = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.width;
    return Size.fromHeight(screenWidth < 600 ? 120.0 : 80.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Material(
      elevation: 4.0,
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo and Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/logoo.jpg',
                              fit: BoxFit.contain,
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Investo",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        _buildAdminLoginButton(context),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Horizontal scrollable navigation for mobile
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildNavItem(context, "Home", '/'),
                          const SizedBox(width: 15),
                          _buildNavItem(context, "About", '/about'),
                          const SizedBox(width: 15),
                          _buildNavItem(context, "FAQ", '/faq'),
                          const SizedBox(width: 15),
                          _buildNavItem(context, "Contact", '/contact'),
                          const SizedBox(width: 15),
                          _buildNavItem(context, "Analytics", '/analytics'),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo and Title
                    Row(
                      children: [
                        Image.asset(
                          'assets/logoo.jpg',
                          fit: BoxFit.contain,
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "MLM",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Navigation items
                    Row(
                      children: [
                        _buildNavItem(context, "Home", '/'),
                        const SizedBox(width: 20),
                        _buildNavItem(context, "About", '/about'),
                        const SizedBox(width: 20),
                        _buildNavItem(context, "FAQ", '/faq'),
                        const SizedBox(width: 20),
                        _buildNavItem(context, "Contact", '/contact'),
                        const SizedBox(width: 20),
                        _buildNavItem(context, "Analytics", '/analytics'),
                        const SizedBox(width: 20),
                        _buildAdminLoginButton(context),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/admin-login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[600],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        "Admin Login",
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}