import 'package:audioguia_web/provider/monumentos_provider.dart';
import 'package:audioguia_web/provider/rendimiento_provider.dart';
import 'package:audioguia_web/provider/auth_provider.dart';
import 'package:audioguia_web/provider/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:audioguia_web/config/router/app_router.dart';
import 'package:audioguia_web/provider/noticia_provider.dart';
import 'package:audioguia_web/provider/tema_provider.dart';
import 'package:audioguia_web/provider/config_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://axhthfoqdxickibsblrq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4aHRoZm9xZHhpY2tpYnNibHJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3NDkwMTEsImV4cCI6MjA4OTMyNTAxMX0.3ZDRL88ElYlUOyf4T5N_YX3OeT4mHXhT9SCGPndzPGc',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoticiaProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TemaProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
        ChangeNotifierProvider(create: (_) => RendimientoProvider()),
        ChangeNotifierProvider(create: (_) => GestionMonumentoProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<TemaProvider>().isDarkMode;

    return MaterialApp.router(
      title: 'Audioguía Admin',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6A4F)),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          brightness: Brightness.dark,
        ),
        cardColor: const Color(0xFF1E2A3A),
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Roboto',
      ),
    );
  }
}
