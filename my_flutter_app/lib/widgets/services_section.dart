import 'package:flutter/material.dart';

class ServicesSection extends StatelessWidget {
  // List of services
  final List<Map<String, String>> services = [
    {
      "title": "Global",
      "description": "We support a variety of the most popular digital currencies.",
    },
    {
      "title": "Support",
      "description": "We always provide the best support to all our users.",
    },
    {
      "title": "Crypto",
      "description": "Cryptocurrency stored on our servers is covered by our insurance policy.",
    },
    {
      "title": "Language",
      "description": "This site can be easily translated into your own language.",
    },
    {
      "title": "Secure",
      "description": "Gives ultimate security with 2FA authentication with this system.",
    },
    {
      "title": "Profitable",
      "description": "You can get the golden opportunity to actually win a lot of profit here.",
    },
  ];

  ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200], // Light gray background
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title Section
          Text(
            'Our Services',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Why We are The Best',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Necessitatibus sapiente ex enim omnis, commodo doloribus sequi corrupti error maiores inventore.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 24),

          // Grid View for Services
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive Grid: 1 column for small screens, 3 columns for larger
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        // Add functionality if needed
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              service['title']!,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              service['description']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
