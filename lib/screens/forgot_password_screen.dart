import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  Future<void> _sendResetEmail() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Masukkan email kamu dulu!');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'Email tidak terdaftar.';
            break;
          case 'invalid-email':
            _errorMessage = 'Format email tidak valid.';
            break;
          default:
            _errorMessage = 'Gagal mengirim email. Coba lagi.';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          child: SingleChildScrollView(  // ← Add this to make content scrollable
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF0A4F66), size: 16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text('MOVERSE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: Color(0xFF0A6E85),
                      )),
                  const SizedBox(height: 20),

                  const Text('Lupa\nPassword?',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A1628),
                          height: 1.1)),

                  const SizedBox(height: 12),
                  const Text(
                    'Tenang! Masukkan email kamu dan kami akan kirimkan link untuk reset password.',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
                  ),

                  const SizedBox(height: 40),

                  // Email sent success state
                  if (_emailSent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0ABFDB).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                              ),
                            ),
                            child: const Icon(Icons.mark_email_read_outlined,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 20),
                          const Text('Email Terkirim!',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A1628))),
                          const SizedBox(height: 8),
                          Text(
                            'Link reset password sudah dikirim ke\n${_emailController.text.trim()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cek folder spam jika tidak muncul di inbox.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)]),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                ),
                                child: const Text('Kembali ke Login',
                                    style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
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

                    // Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0ABFDB).withOpacity(0.1),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('EMAIL ADDRESS',
                              style: TextStyle(
                                  fontSize: 11,
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
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)]),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendResetEmail,
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
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Kirim Link Reset',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),  // ← Reduced from Spacer()

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Ingat password?  ',
                          style:
                              TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                  color: Color(0xFF0A1628),
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
      ),
    );
  }
}