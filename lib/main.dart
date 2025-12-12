// lib/main.dart - Fixed with proper routing
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:skt_desa/screens/admin/admin_chat_screen.dart';
import 'package:skt_desa/screens/user/chat_screen.dart';
import 'package:skt_desa/screens/user/faq_screen.dart';
import 'package:skt_desa/screens/user/layanan_screen.dart';
import 'package:skt_desa/screens/user/profile_screen.dart';
import 'package:skt_desa/screens/user/service_selection_screen.dart';
import 'package:skt_desa/services/auth_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/surat_provider.dart';
import 'providers/berita_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => SuratProvider()),
        ChangeNotifierProvider(create: (context) => BeritaProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layanan Surat Online Nagari',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.primaryColor,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      // Define routes properly
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.adminDashboard: (context) => const DashboardScreen(),
        AppRoutes.serviceSelection: (context) => const ServiceSelectionScreen(),
        AppRoutes.layanan: (context) => const LayananScreen(),
        AppRoutes.faq: (context) => const FAQScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.chat: (context) => const ChatScreen(),
      },
      // Set initial route based on auth state
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.currentUser?.role == 'admin') {
              return const DashboardScreen();
            }
            return const LoginScreen();
          }
        },
      ),
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}