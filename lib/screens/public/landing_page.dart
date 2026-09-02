import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _authCardKey = GlobalKey();

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  // Login Controllers
  final _emailLoginController =
      TextEditingController(text: 'member@ansarfamily.org');
  final _passLoginController = TextEditingController(text: 'password123');

  // Signup Controllers
  final _usernameRegisterController = TextEditingController();
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
    _scrollController.dispose();
    _emailLoginController.dispose();
    _passLoginController.dispose();
    _usernameRegisterController.dispose();
    _emailRegisterController.dispose();
    _passRegisterController.dispose();
    _nameRegisterController.dispose();
    _phoneRegisterController.dispose();
    _addressRegisterController.dispose();
    super.dispose();
  }

  void _scrollToAuthForm() {
    final context = _authCardKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
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
          SnackBar(
              content: Text(auth.errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleSignUp() async {
    if (_formKeyRegister.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.signUp(
        username: _usernameRegisterController.text.trim(),
        email: _emailRegisterController.text.trim(),
        password: _passRegisterController.text.trim(),
        fullName: _nameRegisterController.text.trim(),
        phone: _phoneRegisterController.text.trim(),
        address: _addressRegisterController.text.trim(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registration submitted! Account pending management approval.'),
            backgroundColor: AppTheme.primaryEmerald,
          ),
        );
      } else if (mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(auth.errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: AppTheme.primaryEmerald,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.volunteer_activism,
                  color: AppTheme.primaryEmerald, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ANSAR FAMILY',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1),
                ),
                Text(
                  'Local Muslim Community Platform',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (isDesktop) ...[
            TextButton(
              onPressed: _scrollToAuthForm,
              child:
                  const Text('Overview', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: _scrollToAuthForm,
              child: const Text('Community Pillars',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
          ],
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(0);
              _scrollToAuthForm();
            },
            icon: const Icon(Icons.login, size: 16),
            label: const Text('Sign In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(1);
              _scrollToAuthForm();
            },
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Join Us'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryEmerald,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // HERO SECTION
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
                vertical: isDesktop ? 72 : 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryEmerald, AppTheme.primaryTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  color: AppTheme.secondaryGold, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'COMMUNITY EMPOWERMENT & MUTUAL AID',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Empowering Local Muslim Communities\nThrough Unity & Transparent Support',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 40 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ansar Family connects households in brotherhood. Easily manage membership requests, family dependents, assistance posts, and charity fee collections with full audit transparency.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _tabController.animateTo(1);
                                _scrollToAuthForm();
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Apply for Membership'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryGold,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 16),
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _tabController.animateTo(0);
                                _scrollToAuthForm();
                              },
                              icon: const Icon(Icons.lock_open,
                                  color: Colors.white),
                              label: const Text('Member Portal Sign In',
                                  style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.white, width: 1.5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // COMMUNITY PILLARS / OVERVIEW SECTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    const Text(
                      'CORE COMMUNITY SERVICES',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Designed for Seamless Community Empowerment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Grid of 4 Pillars
                    GridView.count(
                      crossAxisCount: isDesktop
                          ? 4
                          : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.1,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.groups,
                          title: 'Family Dependents',
                          desc:
                              'Register household members and dependents linked to your profile for community welfare tracking.',
                          color: AppTheme.primaryEmerald,
                        ),
                        _buildFeatureCard(
                          icon: Icons.handshake,
                          title: 'Assistance Requests',
                          desc:
                              'Post community service requests, volunteering calls, food drives, and educational halaqahs.',
                          color: AppTheme.primaryTeal,
                        ),
                        _buildFeatureCard(
                          icon: Icons.volunteer_activism,
                          title: 'Fees & Sadaqah',
                          desc:
                              'Zero-cost transparent fee collection, general charity contributions, and microfinance records.',
                          color: AppTheme.secondaryGold,
                        ),
                        _buildFeatureCard(
                          icon: Icons.workspace_premium,
                          title: 'Digital Certificates',
                          desc:
                              'Download official printable membership certificates with verification seal and issue dates.',
                          color: AppTheme.accentMint,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 56),

            // INTEGRATED AUTHENTICATION & REGISTRATION SECTION
            Container(
              key: _authCardKey,
              width: double.infinity,
              color: Colors.grey.shade100,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: CustomCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryEmerald,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_outlined,
                              size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Community Member Portal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to access your dashboard or submit a membership request.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 20),

                        TabBar(
                          controller: _tabController,
                          labelColor: AppTheme.primaryEmerald,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppTheme.primaryEmerald,
                          tabs: const [
                            Tab(text: 'Member Sign In'),
                            Tab(text: 'Register Account'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 350,
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
                                          labelText:
                                              'Email Address or Username',
                                          prefixIcon:
                                              Icon(Icons.email_outlined),
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'Enter email or username'
                                            : null,
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _passLoginController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: Icon(Icons.lock_outline),
                                        ),
                                        validator: (v) =>
                                            v == null || v.length < 6
                                                ? 'Min 6 characters'
                                                : null,
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: auth.isLoading
                                              ? null
                                              : _handleSignIn,
                                          child: auth.isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2),
                                                )
                                              : const Text(
                                                  'Sign In to Dashboard'),
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
                                          prefixIcon:
                                              Icon(Icons.person_outline),
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'Required'
                                            : null,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _usernameRegisterController,
                                        decoration: const InputDecoration(
                                          labelText: 'Username (Unique ID)',
                                          prefixIcon:
                                              Icon(Icons.alternate_email),
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'Required'
                                            : null,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _emailRegisterController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email Address',
                                          prefixIcon:
                                              Icon(Icons.email_outlined),
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'Required'
                                            : null,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _passRegisterController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: Icon(Icons.lock_outline),
                                        ),
                                        validator: (v) =>
                                            v == null || v.length < 6
                                                ? 'Min 6 chars'
                                                : null,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _phoneRegisterController,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon:
                                              Icon(Icons.phone_outlined),
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
                                          onPressed: auth.isLoading
                                              ? null
                                              : _handleSignUp,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.primaryTeal),
                                          child: auth.isLoading
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white)
                                              : const Text(
                                                  'Submit Application'),
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
                          'DEMO DASHBOARD PREVIEW (CLICK TO TEST ROLE):',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => auth.switchDemoRole('admin'),
                              icon: const Icon(Icons.security, size: 14),
                              label: const Text('Admin',
                                  style: TextStyle(fontSize: 11)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  auth.switchDemoRole('management'),
                              icon: const Icon(Icons.work, size: 14),
                              label: const Text('Manager',
                                  style: TextStyle(fontSize: 11)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => auth.switchDemoRole('member'),
                              icon: const Icon(Icons.person, size: 14),
                              label: const Text('Member',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FOOTER
            Container(
              padding: const EdgeInsets.all(24),
              color: AppTheme.textDark,
              child: const Center(
                child: Text(
                  '© 2026 Ansar Family Community Empowerment Platform. All rights reserved.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
