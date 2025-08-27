import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '/widgets/custome_appbar.dart';
import '../widgets/about_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/services_section.dart';
import '../widgets/get_started_section.dart';
import '../widgets/footer_section.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[200],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Minimal gap, can set to 0 if you want no space at all
                SizedBox(height: isMobile ? 12.0 : 8.0),
                HeroSection(),
                AboutSection(),
                ServicesSection(),
                GetStartedSection(),
                FooterSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
