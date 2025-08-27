import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and Copyright
          Row(
            children: [
              Image.asset('assets/logoo.jpg', height: 60),
              SizedBox(width: 10),
              Text(
                'Investo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Copyright © 2025 MLM.'),
          Text(
            'Website designed by Daniyal Haider',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          SizedBox(height: 20),

          // Certifications
          Center(
            child: Text(
              'Arizona ROC 182765 | California CSLB 1010995 | Georgia GCQA005629\n'
              'Iowa C147053 | Nevada 0080017 | New Mexico 400982 | Ohio LCG-2022-0256\n'
              'Oregon 207399 | Tennessee BC-B 75974 | Texas BU124952 | Utah 12258364-5501\n'
              'Virginia 2705168809 | Washington State GCONI | *831N4',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
          ),

          SizedBox(height: 20),

          // Contact Info
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '623.581.6300',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'HEADQUARTERS:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text('1606 W. Whispering Wind Dr.\nPhoenix, Arizona 85085'),

                // Social Media Icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.facebookF),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.linkedinIn),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.instagram),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Divider
          Divider(color: Colors.grey[700]),
        ],
      ),
    );
  }
}
