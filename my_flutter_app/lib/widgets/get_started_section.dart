import 'package:flutter/material.dart';

class GetStartedSection extends StatelessWidget {
  // List of steps with icons and titles
  final List<Map<String, String>> steps = [
    {
      "icon": "assets/add-user.png",
      "title": "Create An Account",
    },
    {
      "icon": "assets/tap.png",
      "title": "Choose Plan",
    },
    {
      "icon": "assets/add-group.png",
      "title": "Invite More People",
    },
    {
      "icon": "assets/comission.png",
      "title": "Get Commission",
    },
  ];

  GetStartedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[800], // Background color
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title Section
          Text(
            'How to Get Started',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Necessitatibus sapiente ex earum omnis, commodi doloribus! Iste corrupti error maiores inventore.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          SizedBox(height: 24),

          // Responsive Row or Column based on screen width
          LayoutBuilder(
            builder: (context, constraints) {
              // Switch between row and column
              bool isWide = constraints.maxWidth > 600;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: steps.map((step) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Icon Container with Yellow Triangle
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  step['icon']!,
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                            // Yellow Triangle
                            if (step['title'] == "Create An Account")
                              Positioned(
                                bottom: -10,
                                child: CustomPaint(
                                  painter: TrianglePainter(),
                                  child: SizedBox(width: 16, height: 16),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          step['title']!,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Yellow Triangle
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow[500]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
