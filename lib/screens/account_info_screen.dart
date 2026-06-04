import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController(text: '••••••••••••');
  bool _obscurePass = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        final data = doc.data();
        setState(() {
          _nameController.text = data?['name'] ?? '';
          _emailController.text = data?['email'] ?? user.email ?? '';
          _phoneController.text = data?['phone'] ?? '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        });

        // Update email di Firebase Auth jika berubah
        if (_emailController.text.trim() != user.email) {
          await user.verifyBeforeUpdateEmail(_emailController.text.trim());
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'email': _emailController.text.trim()});
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perubahan disimpan!'),
              backgroundColor: Color(0xFF0ABFDB),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF0A4F66), size: 16),
                    ),
                  ),
                  const Expanded(
                    child: Text('Account Info',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A4F66))),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF0ABFDB)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Center(
                            child: Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                                ),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.person,
                                  size: 54, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text('ACCOUNT DETAILS',
                              style: TextStyle(fontSize: 11, letterSpacing: 1.5,
                                  color: Color(0xFF0ABFDB), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Information',
                              style: TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
                          const SizedBox(height: 24),

                          // Form card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0ABFDB).withOpacity(0.08),
                                  blurRadius: 20, offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('FULL NAME'),
                                _buildField(
                                    controller: _nameController,
                                    icon: Icons.person_outline),
                                const SizedBox(height: 18),

                                _buildLabel('EMAIL ADDRESS'),
                                _buildField(
                                    controller: _emailController,
                                    icon: Icons.mail_outline,
                                    type: TextInputType.emailAddress),
                                const SizedBox(height: 18),

                                _buildLabel('PHONE NUMBER'),
                                _buildField(
                                    controller: _phoneController,
                                    icon: Icons.phone_outlined,
                                    type: TextInputType.phone),
                                const SizedBox(height: 18),

                                _buildLabel('PASSWORD'),
                                _buildField(
                                  controller: _passController,
                                  icon: Icons.lock_outline,
                                  obscure: _obscurePass,
                                  readOnly: true,
                                  toggleObscure: () =>
                                      setState(() => _obscurePass = !_obscurePass),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)]),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveChanges,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100)),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2))
                                        : const Text('Save Changes',
                                            style: TextStyle(fontSize: 15,
                                                fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0ABFDB),
                                    side: const BorderSide(color: Color(0xFF0ABFDB)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100)),
                                  ),
                                  child: const Text('Cancel',
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 1.2, color: Color(0xFF0A1628))),
      );

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    bool readOnly = false,
    VoidCallback? toggleObscure,
  }) =>
      TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        readOnly: readOnly,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0ABFDB), size: 20),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey, size: 20,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );
}