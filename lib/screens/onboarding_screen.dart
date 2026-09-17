import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'auth/login_screen.dart';

const navy = Color(0xFF0A1128);
const accentBlue = Color(0xFF1E40AF);
const accentCyan = Color(0xFF0EA5E9);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      icon: Icons.calculate_outlined,
      title: 'Track your CGPA',
      subtitle:
          'Add subjects and grades to instantly calculate your CGPA and SGPA every semester',
      gradient: [accentBlue, accentCyan],
    ),
    _OnboardData(
      icon: Icons.schedule_outlined,
      title: 'Daily timetable',
      subtitle:
          "See today's classes, faculty, and room numbers at a glance, organized by day",
      gradient: [accentCyan, Color(0xFF14B8A6)],
    ),
    _OnboardData(
      icon: Icons.celebration_outlined,
      title: 'Holiday calendar',
      subtitle:
          'Stay ahead with a full list of upcoming holidays and academic dates',
      gradient: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
    _OnboardData(
      icon: Icons.people_outline,
      title: 'Faculty directory',
      subtitle:
          'Find teacher contacts, office hours, and office locations in seconds',
      gradient: [Color(0xFF10B981), accentCyan],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blurred circles
            Positioned(
              top: -60,
              right: -60,
              child: _BlurCircle(
                size: 180,
                color: accentBlue.withOpacity(0.25),
              ),
            ),
            Positioned(
              bottom: 160,
              left: -50,
              child: _BlurCircle(
                size: 140,
                color: accentCyan.withOpacity(0.15),
              ),
            ),

            Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) =>
                        _OnboardPage(data: _pages[index]),
                  ),
                ),

                // Indicator + Next button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: accentBlue,
                          dotColor: const Color(0xFF334155),
                          dotHeight: 6,
                          dotWidth: 6,
                          expansionFactor: 4,
                          spacing: 8,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentPage + 1} / ${_pages.length}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: _next,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: accentBlue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentBlue.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.check
                                    : Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;

  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradient,
              ),
            ),
            child: Icon(data.icon, color: Colors.white, size: 64),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
