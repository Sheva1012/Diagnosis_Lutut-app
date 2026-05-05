import 'dart:async'; // Tambahkan ini untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import '../admin/admin_dashboard.dart';
import '../masyarakat/home_masyarakat.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  late final StreamSubscription<AuthState> _authSubscription;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const String _emailHistoryKey = 'login_email_history';
  List<String> _emailHistory = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    _loadEmailHistory();

    // Mendengarkan perubahan status autentikasi (Berguna untuk menangani kembalinya dari Browser saat Google Login)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _addEmailToHistory(session.user.email ?? _emailController.text.trim());
        _checkRoleAndRedirect(session.user.id);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _authSubscription.cancel(); // Jangan lupa batalkan subscription
    super.dispose();
  }

  Future<void> _loadEmailHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList(_emailHistoryKey) ?? <String>[];
    if (mounted) {
      setState(() => _emailHistory = emails);
    } else {
      _emailHistory = emails;
    }
  }

  Future<void> _addEmailToHistory(String? email) async {
    final normalized = email?.trim();
    if (normalized == null || normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_emailHistoryKey) ?? <String>[];

    current.removeWhere((item) => item.toLowerCase() == normalized.toLowerCase());
    current.insert(0, normalized);

    final limited = current.take(8).toList();
    await prefs.setStringList(_emailHistoryKey, limited);

    if (mounted) {
      setState(() => _emailHistory = limited);
    } else {
      _emailHistory = limited;
    }
  }

  // --- FUNGSI CEK ROLE & REDIRECT ---
  Future<void> _checkRoleAndRedirect(String userId) async {
    try {
      // Ambil data Role dari tabel 'users' berdasarkan ID user yang login
      final userData = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_user', userId)
          .maybeSingle();

      // Secara default, jika login via Google dan belum ada di tabel users, anggap 'Masyarakat'
      final String role = (userData != null && userData['role'] != null)
          ? userData['role']
          : 'Masyarakat';

      if (mounted) {
        if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeMasyarakat()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memverifikasi user role.')),
        );
      }
    }
  }

  // --- FUNGSI LOGIN GOOGLE ---
  Future<void> _loginWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        // Parameter ini WAJIB ada agar browser bisa kembali ke aplikasi Anda
        redirectTo: 'com.kneecheck.app://login-callback/',
      );
      // Tidak perlu redirect di sini, karena akan ditangani oleh _authSubscription di initState
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat login Google.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- FUNGSI LOGIN EMAIL & PASSWORD ---
  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // Proses Login ke Supabase Auth
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Tidak perlu redirect di sini, karena event signedIn akan dipicu dan ditangani oleh _authSubscription
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Gagal: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan. Cek koneksi internet.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F7FC), Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 120,
                          width: 120,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo-kmc.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 64), 

                    // Form Email
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: RawAutocomplete<String>(
                        textEditingController: _emailController,
                        focusNode: _emailFocusNode,
                        displayStringForOption: (option) => option,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final query = textEditingValue.text.trim();
                          if (query.length < 2) {
                            return const Iterable<String>.empty();
                          }
                          final q = query.toLowerCase();
                          return _emailHistory.where(
                            (email) => email.toLowerCase().contains(q),
                          );
                        },
                        onSelected: (selection) {
                          _emailController.text = selection;
                          _emailController.selection = TextSelection.fromPosition(
                            TextPosition(offset: selection.length),
                          );
                        },
                        fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController textController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          return TextField(
                            controller: textController,
                            focusNode: focusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                              floatingLabelStyle: GoogleFonts.poppins(color: const Color(0xFF4285F4), fontWeight: FontWeight.w600),
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (
                          BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options,
                        ) {
                          final optionList = options.toList();
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.white,
                              elevation: 6,
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: optionList.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey[200],
                                  ),
                                  itemBuilder: (context, index) {
                                    final option = optionList[index];
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Text(
                                          option,
                                          style: GoogleFonts.poppins(fontSize: 14),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Form Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                          floatingLabelStyle: GoogleFonts.poppins(color: const Color(0xFF4285F4), fontWeight: FontWeight.w600),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Button Login
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4285F4).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 32),

                    // --- Garis Pembatas "OR" ---
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Or continue with",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Button Login Google
                    OutlinedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset('assets/images/icon-google.png', height: 24),
                      label: Text(
                        "Sign in with Google",
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                        elevation: 0,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Register Link
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF4285F4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
