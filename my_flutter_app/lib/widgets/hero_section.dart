import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallMobile = size.width < 400; // Added for very small devices

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.purple[800],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 16 : 20,
        vertical: isSmallMobile ? 20 : 30,
      ),
      margin: EdgeInsets.only(top: 30, left: 16, right: 16), // Added side margins for mobile
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text Section
          ZoomIn(
            duration: Duration(seconds: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInLeft(
                  duration: Duration(milliseconds: 800),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 8 : 0),
                    child: Text(
                      "Multilevel Marketing Platform",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallMobile ? 22 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                FadeInUp(
                  duration: Duration(milliseconds: 800),
                  delay: Duration(milliseconds: 300),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 8 : 0),
                    child: Text(
                      "Win more commissions by making more members and increase your capital. "
                      "You can earn money by viewing ads on our site.", // Shortened for mobile
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallMobile ? 14 : 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                FadeInUp(
                  duration: Duration(milliseconds: 800),
                  delay: Duration(milliseconds: 500),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallMobile ? 16 : 20,
                            vertical: isSmallMobile ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(fontSize: isSmallMobile ? 14 : 16),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallMobile ? 16 : 20,
                            vertical: isSmallMobile ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: Text(
                          "Sign In",
                          style: TextStyle(fontSize: isSmallMobile ? 14 : 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Image Section - Moved below text for better mobile flow
          SizedBox(height: 20),
         FadeInRight(
  duration: Duration(seconds: 1),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.asset(
      'assets/ml.png',
      fit: BoxFit.contain,  // Changed from BoxFit.cover to BoxFit.contain
      width: size.width * 0.8, // Consistent width for all mobiles
      height: size.width * 0.5, // Proportional height
    ),
  ),
),

        ],
      ),
    );
  }
}