import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/class_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/theme_provider.dart';

void main() {
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'نظام إدارة الطلاب',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const DashboardScreen(),
            debugShowCheckedModeBanner: false,
            // Localization settings for Arabic and RTL support
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ar', ''), // Arabic
            ],
            locale: const Locale('ar', ''), // Set default locale to Arabic
          );
        },
      ),
    );
  }
}

class AppTheme {
  // Define a primary seed color for a vibrant look
  static const MaterialColor primarySeedColor = Colors.deepPurple; // Changed to MaterialColor

  // Define a common TextTheme using GoogleFonts.amiri
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
    textTheme: _appTextTheme, // Use the common text theme
    appBarTheme: AppBarTheme(
      backgroundColor: primarySeedColor, // Use a vibrant color for AppBar
      foregroundColor: Colors.white, // White text/icons on AppBar
      titleTextStyle: _appTextTheme.headlineSmall?.copyWith(
        color: Colors.white, // Ensure title is white
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
      elevation: 4, // Add a subtle shadow to cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ), // Removed const
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
    textTheme: _appTextTheme, // Use the common text theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900], // Darker AppBar for dark mode
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
    ), // Removed const
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primarySeedColor.shade200, width: 2),
      ),
    ),
  );
}
