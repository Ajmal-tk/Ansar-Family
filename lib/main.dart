import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'screens/management/management_dashboard.dart';
import 'screens/public/landing_page.dart';
import 'screens/public/public_portal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if configured with credentials
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint("Supabase init error: $e");
    }
  }

  runApp(const AnsarFamilyApp());
}

class AnsarFamilyApp extends StatelessWidget {
  const AnsarFamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Ansar Family',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Authentication & Role-Based Routing Wrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryEmerald),
              SizedBox(height: 16),
              Text(
                'Loading Ansar Family Platform...',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    // IF NOT AUTHENTICATED: Display Public Landing Page with embedded login/register
    if (!auth.isAuthenticated) {
      return const LandingPage();
    }

    // IF LOGGED IN: Route dynamically based on role & status
    final profile = auth.currentProfile;
    if (profile?.isAdmin ?? false) {
      return const ManagementDashboard();
    } else if (profile?.isManagement ?? false) {
      return const ManagementDashboard();
    } else {
      return const PublicPortal();
    }
  }
}
