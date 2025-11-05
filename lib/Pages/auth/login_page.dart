import 'package:Nexora/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import '../../Providers/auth_provider.dart';
import '../../Providers/news_provider.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSwitchToSignup;

  const LoginPage({Key? key, required this.onSwitchToSignup}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // MATCH NAV BUTTON HEIGHT (do NOT change nav code)
  static const double buttonHeight = Constants.buttonHeight;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        await authProvider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        // Login successful
        if (mounted) {
          // Refresh news data
          await newsProvider.fetchArticles();

          // Show success message
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(message: 'Login successful'),
          );
          // Close the modal
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred during login.';
        if (e.code == 'user-not-found') {
          message = 'Login error: No user found for that email.';
        } else if (e.code == 'invalid-credential') {
          message = 'Login error: Invalid Credentials';
        } else {
          // For debugging, show the actual error code
          message = 'Login error: ${e.code}';
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
      // keep horizontal padding but minimal vertical padding (we force height via SizedBox)
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
      // padding moved into the container so top border aligns correctly inside the modal sheet
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // Primary-colored top border only (keeps other sides untouched)
        border: Border(top: BorderSide(color: Colors.white, width: 2)),
        // Rounded top corners suitable for a modal bottom sheet
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login',
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
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(
              height: 16,
            ), // keep same spacing before the button as signup
            // Button matching the nav button height
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(buttonHeight),
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
                            'Login',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onSwitchToSignup,
              child: Text(
                'Don\'t have an account? Sign up',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
