import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreed = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    if (_passController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Password tidak sama!');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Nama tidak boleh kosong!');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Buat akun di Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      // Simpan data user ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'level': 1,
        'xp': 0,
        'totalDistance': 0.0,
        'totalSteps': 0,
        'achievements': 0,
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'weak-password':
            _errorMessage = 'Password terlalu lemah (minimal 6 karakter).';
            break;
          case 'email-already-in-use':
            _errorMessage = 'Email sudah terdaftar.';
            break;
          case 'invalid-email':
            _errorMessage = 'Format email tidak valid.';
            break;
          default:
            _errorMessage = 'Registrasi gagal. Coba lagi.';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
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
            colors: [Color(0xFFB8EDF8), Color(0xFFDEF5FB), Color(0xFFF0FAFE)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 80, right: -30,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: const [
                          Text('MOVERSE',
                              style: TextStyle(fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  color: Color(0xFF0A4F66))),
                          SizedBox(height: 6),
                          Text('The Kinetic Flow of Motion',
                              style: TextStyle(fontSize: 13,
                                  color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text('Create Your\nAccount',
                        style: TextStyle(fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1628), height: 1.2)),
                    const SizedBox(height: 10),
                    Container(
                      width: 44, height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0ABFDB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 28),

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

                    _buildLabel('FULL NAME'),
                    _buildField(controller: _nameController,
                        hint: 'John Doe', icon: Icons.person_outline),
                    const SizedBox(height: 18),

                    _buildLabel('GMAIL ADDRESS'),
                    _buildField(controller: _emailController,
                        hint: 'john@gmail.com', icon: Icons.mail_outline,
                        type: TextInputType.emailAddress),
                    const SizedBox(height: 18),

                    _buildLabel('PASSWORD'),
                    _buildField(
                      controller: _passController, hint: '••••••••',
                      icon: Icons.lock_outline, obscure: _obscurePass,
                      toggleObscure: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('CONFIRM PASSWORD'),
                    _buildField(
                      controller: _confirmController, hint: '••••••••',
                      icon: Icons.shield_outlined, obscure: _obscureConfirm,
                      toggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                          activeColor: const Color(0xFF0ABFDB),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        RichText(
                          text: const TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(color: Color(0xFF6B7280),
                                fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(color: Color(0xFF0ABFDB),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _agreed
                            ? const LinearGradient(
                                colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)])
                            : null,
                        color: _agreed
                            ? null
                            : const Color(0xFF0ABFDB).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ElevatedButton(
                        onPressed: (_agreed && !_isLoading) ? _signUp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('SIGN UP',
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account?  ',
                            style: TextStyle(color: Color(0xFF6B7280),
                                fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(color: Color(0xFF0A1628),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 1.3, color: Color(0xFF0A1628))),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) =>
      TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB0C4CC)),
          prefixIcon: Icon(icon, color: const Color(0xFF0ABFDB), size: 20),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey, size: 20,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      );
}