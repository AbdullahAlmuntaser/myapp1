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
import 'database_helper.dart'; // Import DatabaseHelper
import 'screens/grades_screen.dart'; // Import GradesScreen
import 'screens/attendance_screen.dart'; // Import AttendanceScreen

// Define an interface for initializable providers
abstract class InitializableProvider {
  Future<void> initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure the database is initialized once and globally accessible
  // No need to await here, it will be awaited by providers when they access `database`
  DatabaseHelper(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
              // Moved route definitions here.
              GradesScreen.routeName: (context) => const GradesScreen(),
              AttendanceScreen.routeName: (context) => const AttendanceScreen(),
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
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    // Access providers after the widget tree is built and providers are available
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    // Call fetch methods on each provider that needs to fetch initial data
    await Future.wait([
      studentProvider.fetchStudents(),
      teacherProvider.fetchTeachers(),
      classProvider.fetchClasses(),
      subjectProvider.fetchSubjects(),
      gradeProvider.initialize(), 
      attendanceProvider.initialize(), 
      timetableProvider.fetchTimetableEntries(),
    ]);

    // After all initial data is fetched, set initialized state
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return const DashboardScreen();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: _appTextTheme.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: _appTextTheme.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
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