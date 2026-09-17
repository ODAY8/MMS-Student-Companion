import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_app/screens/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/cgpa_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/academic_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/profile_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/assignment_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialise notifications before the app renders
  //await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CGPAProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => AcademicProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
      ],
      child: MaterialApp(
        title: 'Student Companion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2563EB),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    debugPrint('AUTH GATE BUILD: ${authProvider.status}');

    switch (authProvider.status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthStatus.authenticated:
        return const HomeScreen();

      case AuthStatus.unauthenticated:
        return const OnboardingScreen();
    }
  }
}
