import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseAuth auth;

  const LoginScreen({super.key, required this.auth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Form ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;

  // ── State ─────────────────────────────────────────────────
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Colors (matched to your splash/theme) ─────────────────
  static const Color _primary = Color(0xFF1D9E75);
  static const Color _primaryDark = Color(0xFF0F6E56);
  static const Color _textDark = Color(0xFF1C2833);
  static const Color _textMuted = Color(0xFF5D6D7E);
  static const Color _textHint = Color(0xFFAEB6BF);
  static const Color _border = Color(0xFFE5E8E8);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _bg = Color(0xFFF4F7F5);

  // ── Cleanup ───────────────────────────────────────────────
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Navigation helper ─────────────────────────────────────
  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ── Snackbar helper ───────────────────────────────────────
  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE74C3C) : _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ── Error mapping ─────────────────────────────────────────
  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // ── Set loading / error state ─────────────────────────────
  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
      if (value) _errorMessage = null;
    });
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  // ── EMAIL SIGN IN ─────────────────────────────────────────
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      await widget.auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _showSnack('Welcome back!');
      _goHome();
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } catch (_) {
      _setError('Sign in failed.');
    }
  }

  // ── EMAIL SIGN UP ─────────────────────────────────────────
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      final cred = await widget.auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await cred.user?.updateDisplayName(_nameController.text.trim());
      _showSnack('Account created!');
      _goHome();
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } catch (_) {
      _setError('Account creation failed.');
    }
  }

  // ── GOOGLE SIGN IN ────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled
        _setLoading(false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await widget.auth.signInWithCredential(credential);
      _showSnack('Welcome back!');
      _goHome();
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } catch (_) {
      _setError('Google sign-in failed.');
    }
  }

  // ── GUEST MODE ────────────────────────────────────────────
  Future<void> _signInAsGuest() async {
    _setLoading(true);
    try {
      await widget.auth.signInAnonymously();
      _showSnack('Entered guest mode.');
      _goHome();
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } catch (_) {
      _setError('Guest mode failed.');
    }
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnack('Enter a valid email first.', isError: true);
      return;
    }
    try {
      await widget.auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset link sent to your email.'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } catch (_) {
      _setError('Failed to send reset email.');
    }
  }

  // ── Validators ────────────────────────────────────────────
  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Min 6 characters';
    return null;
  }

  String? _nameValidator(String? v) {
    if (!_isSignUp) return null;
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Min 2 characters';
    return null;
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                // ── Logo ─────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    size: 44,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ELIO',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 5,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Smart Waste Sorting Robot',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Title ────────────────────────────────
                Text(
                  _isSignUp ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Join ELIO to start sorting'
                      : 'Sign in to control ELIO',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Error Banner ─────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFE74C3C), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFE74C3C),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _errorMessage = null),
                          child: const Icon(Icons.close,
                              size: 16, color: Color(0xFFE74C3C)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Google Button ────────────────────────
                _buildGoogleButton(),

                const SizedBox(height: 20),

                // ── OR Divider ───────────────────────────
                Row(
                  children: const [
                    Expanded(child: Divider(color: _border)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: _textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: _border)),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Email Form ───────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name (sign up only)
                      if (_isSignUp) ...[
                        _buildTextField(
                          controller: _nameController,
                          validator: _nameValidator,
                          label: 'Full Name',
                          hint: 'John Doe',
                          prefix: Icons.person_outline,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        validator: _emailValidator,
                        label: 'Email',
                        hint: 'you@example.com',
                        prefix: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        validator: _passwordValidator,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefix: Icons.lock_outline,
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: _textHint,
                          ),
                        ),
                      ),

                      // Forgot password (sign in only)
                      if (!_isSignUp) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isSignUp ? _signUpWithEmail : _signInWithEmail),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                _primary.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'Create Account' : 'Sign In',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Toggle Sign In / Sign Up ─────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style:
                          const TextStyle(color: _textMuted, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _isSignUp = !_isSignUp;
                                _errorMessage = null;
                              }),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Sign Up',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Guest Mode ───────────────────────────
                Column(
                  children: [
                    TextButton.icon(
                      onPressed: _isLoading ? null : _signInAsGuest,
                      icon: const Icon(Icons.person_outline, size: 18),
                      label: const Text(
                        'Continue as Guest',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 13, color: _textHint),
                        SizedBox(width: 4),
                        SizedBox(
                          width: 240,
                          child: Text(
                            'Guest mode saves data locally only. Sign in to sync progress.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _textHint,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Text field builder ────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String label,
    required String hint,
    required IconData prefix,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 15, color: _textDark),
      decoration: InputDecoration(
        filled: true,
        fillColor: _surface,
        prefixIcon: Icon(prefix, size: 20, color: _textMuted),
        suffixIcon: suffixIcon,
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE74C3C), width: 2),
        ),
        labelStyle:
            const TextStyle(color: _textMuted, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: _textHint, fontSize: 15),
        errorStyle: const TextStyle(color: Color(0xFFE74C3C), fontSize: 12),
      ),
    );
  }

  // ── Google button ─────────────────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          foregroundColor: _textDark,
          side: const BorderSide(color: _border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Programmatic Google "G" icon
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CustomPaint(painter: _GoogleGPainter()),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Google "G" icon painter (no asset needed) ────────────────
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final p = Paint()..style = PaintingStyle.fill;

    p.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)..lineTo(s * 0.5, 0)..lineTo(s * 0.5, s * 0.5)
        ..lineTo(0, s * 0.5)..close(),
      p,
    );
    p.color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.5, 0)..lineTo(s, 0)..lineTo(s, s * 0.5)
        ..lineTo(s * 0.5, s * 0.5)..close(),
      p,
    );
    p.color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(0, s * 0.5)..lineTo(s * 0.5, s * 0.5)..lineTo(s, s * 0.5)
        ..lineTo(s, s)..lineTo(0, s)..close(),
      p,
    );
    p.color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(0, s * 0.5)..lineTo(s * 0.5, s * 0.5)..lineTo(s * 0.5, s)
        ..lineTo(0, s)..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}