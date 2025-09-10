import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Firebase and Form Controllers
  final _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Graphic
                  _buildHeaderGraphic(),
                  const SizedBox(height: 32),
                  // 2. Welcome Text
                  _buildWelcomeText(),
                  const SizedBox(height: 32),
                  // 3. Form Fields & Buttons (with slide animation)
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildLoginForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderGraphic() {
    return Image.asset(
      'assets/images/login_vector.png', // <-- Make sure you have this asset
      height: 200,
      fit: BoxFit.contain,
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Log in to continue your health journey.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(12),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder.copyWith(
              borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder.copyWith(
              borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Login Button
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            shadowColor: Colors.teal.withAlpha(100),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),

        // ✅ UPDATED: Adjusted spacing after removing the divider and social button.
        const SizedBox(height: 48),

        // Register Text Button
        _buildRegisterButton(),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register!');
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
