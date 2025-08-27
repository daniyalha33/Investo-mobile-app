import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container( // Removed Scaffold
       decoration: BoxDecoration(
        color: Colors.purple[800],
        borderRadius: BorderRadius.circular(20),
      ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Section
            Text(
              'About Us',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '15 Years Of Your Trust',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 24),
      
            // Main Content - Simplified layout
            if (!isMobile) 
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Section
                  Expanded(
                    child: _buildTextContent(),
                  ),
                  SizedBox(width: 20),
                  // Image Section
                  Expanded(
                    child: _buildImage(),
                  ),
                ],
              )
            else 
              Column(
                children: [
                  _buildImage(),
                  SizedBox(height: 20),
                  _buildTextContent(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "We are not just an online version of any Business market, but also the reflection of each and every MLM business...",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'Best Platform with 1000+ happy clients worldwide',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "We will grow your business with 24/7 customer support.",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Explore More'),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/bac.jpeg',
        fit: BoxFit.cover,
        height: 250, // Fixed height for better control
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          height: 250,
          child: Center(child: Icon(Icons.error, color: Colors.red)),
      ),
    ),);
  }
}