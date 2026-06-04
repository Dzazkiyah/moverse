import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'Email tidak ditemukan.';
            break;
          case 'wrong-password':
            _errorMessage = 'Password salah.';
            break;
          case 'invalid-email':
            _errorMessage = 'Format email tidak valid.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti.';
            break;
          default:
            _errorMessage = 'Login gagal. Coba lagi.';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9EE8F5), Color(0xFFD4F3F9), Color(0xFFFFFFFF)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 44),
                const Text('MOVERSE',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      letterSpacing: 3, color: Color(0xFF0A6E85),
                    )),
                const SizedBox(height: 20),
                const Text('Hello,',
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900,
                        color: Color(0xFF0A1628), height: 1.1)),
                const Text('Sign in!',
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900,
                        color: Color(0xFF0A1628), height: 1.1)),
                const SizedBox(height: 36),

                // Error message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Color(0xFFEF4444), fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0ABFDB).withOpacity(0.1),
                        blurRadius: 32, offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('GMAIL ADDRESS',
                          style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                              color: Color(0xFF0A1628))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'username@gmail.com',
                          hintStyle: const TextStyle(color: Color(0xFFB0C4CC)),
                          prefixIcon: const Icon(Icons.mail_outline,
                              color: Color(0xFF0ABFDB), size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PASSWORD',
                              style: TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.3,
                                  color: Color(0xFF0A1628))),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen()),
                            ),
                            child: const Text('Forgot?',
                                style: TextStyle(fontSize: 13,
                                    color: Color(0xFF0ABFDB),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Color(0xFFB0C4CC)),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFF0ABFDB), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey, size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)]),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Sign In  →',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: const TextSpan(
                        text: 'New to the flow?  ',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Create Your Account',
                            style: TextStyle(color: Color(0xFF0A1628),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}