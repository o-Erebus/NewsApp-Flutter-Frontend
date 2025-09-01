import 'package:finalyear/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import '../../Providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const SignupPage({Key? key, required this.onSwitchToLogin}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // MATCH NAV BUTTON HEIGHT (do NOT change nav code)
  // Adjust this value if your nav button height differs.
  static const double buttonHeight = Constants.buttonHeight;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        // Signup successful
        if (mounted) {
          // Show success message
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(message: 'Signup successful. Please login.'),
          );
          // Switch to login page
          widget.onSwitchToLogin();
        }
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred during signup.';
        if (e.code == 'email-already-in-use') {
          message = 'The email address is already in use by another account.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is badly formatted.';
        } else if (e.code == 'weak-password') {
          message = 'The password must be at least 6 characters.';
        } else {
          // For debugging, show the actual error code
          message = 'Signup error: ${e.code}';
        }

        if (mounted) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(message: message),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  InputDecoration _fieldDecoration(String label, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      // Keep horizontal padding but minimal vertical padding — height enforced by SizedBox
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white, width: 2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sign Up',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Email field — forced to buttonHeight
            SizedBox(
              height: buttonHeight,
              child: TextFormField(
                controller: _emailController,
                decoration: _fieldDecoration('Email', colorScheme),
                style: const TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            // Password field — same height
            SizedBox(
              height: buttonHeight,
              child: TextFormField(
                controller: _passwordController,
                decoration: _fieldDecoration('Password', colorScheme),
                style: const TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            // Confirm password — same height
            SizedBox(
              height: buttonHeight,
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: _fieldDecoration('Confirm Password', colorScheme),
                style: const TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            // Button matching the nav button height
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(buttonHeight),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: buttonHeight,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: buttonHeight,
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onSwitchToLogin,
              child: Text(
                'Already have an account? Login',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
