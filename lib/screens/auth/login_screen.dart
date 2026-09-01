import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  // Login Controllers
  final _emailLoginController = TextEditingController(text: 'member@ansarfamily.org');
  final _passLoginController = TextEditingController(text: 'password123');

  // Signup Controllers
  final _emailRegisterController = TextEditingController();
  final _passRegisterController = TextEditingController();
  final _nameRegisterController = TextEditingController();
  final _phoneRegisterController = TextEditingController();
  final _addressRegisterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailLoginController.dispose();
    _passLoginController.dispose();
    _emailRegisterController.dispose();
    _passRegisterController.dispose();
    _nameRegisterController.dispose();
    _phoneRegisterController.dispose();
    _addressRegisterController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (_formKeyLogin.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.signIn(
        _emailLoginController.text.trim(),
        _passLoginController.text.trim(),
      );
      if (!success && mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleSignUp() async {
    if (_formKeyRegister.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.signUp(
        email: _emailRegisterController.text.trim(),
        password: _passRegisterController.text.trim(),
        fullName: _nameRegisterController.text.trim(),
        phone: _phoneRegisterController.text.trim(),
        address: _addressRegisterController.text.trim(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration submitted! Account pending management approval.'),
            backgroundColor: AppTheme.primaryEmerald,
          ),
        );
      } else if (mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryEmerald.withOpacity(0.9),
              AppTheme.primaryTeal.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: CustomCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Brand Logo & Title
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryEmerald,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.diversity_3, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ANSAR FAMILY',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEmerald,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Local Muslim Community Support Platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primaryEmerald,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppTheme.primaryEmerald,
                      tabs: const [
                        Tab(text: 'Sign In'),
                        Tab(text: 'Register Account'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tab View
                    SizedBox(
                      height: 340,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Sign In Form
                          Form(
                            key: _formKeyLogin,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailLoginController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passLoginController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(Icons.lock_outline),
                                    ),
                                    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading ? null : _handleSignIn,
                                      child: auth.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Text('Sign In'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Register Form
                          Form(
                            key: _formKeyRegister,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameRegisterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _emailRegisterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _passRegisterController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(Icons.lock_outline),
                                    ),
                                    validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _phoneRegisterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon: Icon(Icons.phone_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _addressRegisterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Address',
                                      prefixIcon: Icon(Icons.home_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading ? null : _handleSignUp,
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                                      child: auth.isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Text('Submit Application'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 24),

                    // Fast Demo Access Section
                    const Text(
                      'QUICK DEMO ACCESS (CLICK TO SWITCH ROLE):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => auth.switchDemoRole('admin'),
                          icon: const Icon(Icons.security, size: 14),
                          label: const Text('Admin', style: TextStyle(fontSize: 11)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => auth.switchDemoRole('management'),
                          icon: const Icon(Icons.work, size: 14),
                          label: const Text('Manager', style: TextStyle(fontSize: 11)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => auth.switchDemoRole('member'),
                          icon: const Icon(Icons.person, size: 14),
                          label: const Text('Member', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
