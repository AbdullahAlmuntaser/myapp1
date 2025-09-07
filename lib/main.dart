import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/class_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/timetable_provider.dart';
// Removed unused import: import 'database_helper.dart'; 
import 'screens/grades_screen.dart'; // Import GradesScreen
import 'screens/attendance_screen.dart'; // Import AttendanceScreen
import 'services/local_auth_service.dart'; // Import LocalAuthService
import 'screens/login_screen.dart'; // Import LoginScreen
import 'dart:developer' as developer; // Import for logging

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Temporarily commented out to debug database initialization
  // await DatabaseHelper().database; 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalAuthService()), // Add LocalAuthService
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => GradeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'نظام إدارة الطلاب',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(), // Use AppInitializer as the home screen
            routes: {
              GradesScreen.routeName: (context) => const GradesScreen(),
              AttendanceScreen.routeName: (context) => const AttendanceScreen(),
              // Add routes for authentication screens if needed for direct navigation
              '/login': (context) => const LoginScreen(),
            },
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
            ],
            locale: const Locale('ar', ''),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    developer.log('AppInitializer: initState called.', name: 'AppInitializer');
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    developer.log('AppInitializer: Initializing providers...', name: 'AppInitializer');
    // Access providers after the widget tree is built and providers are available
    final authService = Provider.of<LocalAuthService>(context, listen: false);

    // Only fetch data if a user is authenticated. Otherwise, we'll show the login screen.
    if (authService.isAuthenticated) {
      developer.log('AppInitializer: User is authenticated. Fetching data...', name: 'AppInitializer');
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

      await Future.wait([
        studentProvider.fetchStudents(),
        teacherProvider.fetchTeachers(),
        classProvider.fetchClasses(),
        subjectProvider.fetchSubjects(),
        gradeProvider.fetchGrades(),
        attendanceProvider.fetchAttendances(),
        timetableProvider.fetchTimetableEntries(),
      ]);
      developer.log('AppInitializer: Data fetching complete.', name: 'AppInitializer');
    } else {
      developer.log('AppInitializer: User not authenticated. Skipping data fetch.', name: 'AppInitializer');
    }

    // After all initial data is fetched (or if no user is authenticated), set initialized state
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      developer.log('AppInitializer: Initialization complete. Setting _isInitialized to true.', name: 'AppInitializer');
    } else {
      developer.log('AppInitializer: Widget not mounted when trying to set _isInitialized.', name: 'AppInitializer', level: 900);
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('AppInitializer: build called. _isInitialized: $_isInitialized', name: 'AppInitializer');
    if (!_isInitialized) {
      developer.log('AppInitializer: Showing CircularProgressIndicator.', name: 'AppInitializer');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Based on authentication status, show either LoginScreen or the appropriate home screen
    return Consumer<LocalAuthService>(
      builder: (context, authService, child) {
        developer.log('AppInitializer: Consumer rebuilding. isAuthenticated: ${authService.isAuthenticated}', name: 'AppInitializer');
        if (authService.isAuthenticated) {
          developer.log('AppInitializer: User is authenticated. Navigating to role-based home screen.', name: 'AppInitializer');
          // This is where we will introduce role-based navigation
          return _getHomeScreenForRole(authService.currentUser!.role);
        } else {
          developer.log('AppInitializer: User not authenticated. Navigating to LoginScreen.', name: 'AppInitializer');
          return const LoginScreen();
        }
      },
    );
  }

  // New method to return the appropriate home screen based on the user's role
  Widget _getHomeScreenForRole(String role) {
    developer.log('AppInitializer: Getting home screen for role: $role', name: 'AppInitializer');
    switch (role) {
      case 'admin':
        return const DashboardScreen(); // Admin sees the full dashboard
      case 'teacher':
        return const DashboardScreen(); // Teachers might see a modified dashboard or a specific teacher screen
      case 'student':
        return const DashboardScreen(); // Students might see a specific student screen
      // case 'parent': // We will add parent role later
      //   return const ParentDashboardScreen();
      default:
        developer.log('AppInitializer: Unknown role: $role. Falling back to LoginScreen.', name: 'AppInitializer', level: 900);
        return const LoginScreen(); // Fallback to login if role is unknown
    }
  }
}

class AppTheme {
  static const MaterialColor primarySeedColor = Colors.deepPurple;

  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.amiri(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.amiri(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.amiri(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.amiri(fontSize: 28, fontWeight: FontWeight.bold),
    headlineSmall: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.amiri(fontSize: 16),
    bodyMedium: GoogleFonts.amiri(fontSize: 14),
    bodySmall: GoogleFonts.amiri(fontSize: 12),
    labelLarge: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.amiri(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.amiri(fontSize: 11, fontWeight: FontWeight.w500),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: primarySeedColor,
      foregroundColor: Colors.white,
      titleTextStyle: _appTextTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarySeedColor.shade700,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primarySeedColor, width: 2),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      titleTextStyle: _appTextTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarySeedColor.shade200,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySeedColor.shade200,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[800],
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primarySeedColor.shade200, width: 2),
      ),
    ),
  );
}
