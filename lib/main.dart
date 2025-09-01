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
  static final TextTheme _lightTextTheme = GoogleFonts.latoTextTheme(
    ThemeData.light().textTheme,
  );
  static final TextTheme _darkTextTheme = GoogleFonts.latoTextTheme(
    ThemeData.dark().textTheme,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
    textTheme: _lightTextTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle: _lightTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    textTheme: _darkTextTheme,
     appBarTheme: AppBarTheme(
      titleTextStyle: _darkTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
