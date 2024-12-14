// lib/login_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // To show loading indicator
  bool _isLoading = false;

  // For secure storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Function to handle login
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      // Update this URL based on your testing environment
      const String url = 'http://127.0.0.1:8000/api/auth/login/'; // Example for Android Emulator

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        // Log the response status and body
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          // Successfully authenticated
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          // Extract user data and tokens
          String? accessToken = responseData['tokens']['access'];
          String? refreshToken = responseData['tokens']['refresh'];
          String? username = responseData['user']['username']; // Assuming 'username' is available

          // Store tokens and username securely if they are present
          if (accessToken != null) {
            await _storage.write(key: 'access_token', value: accessToken);
          }
          if (refreshToken != null) {
            await _storage.write(key: 'refresh_token', value: refreshToken);
          }
          if (username != null) {
            await _storage.write(key: 'username', value: username);
          }

          // Navigate to home page
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Handle errors
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          String errorMessage = 'An error occurred';

          if (responseData.containsKey('detail')) {
            errorMessage = responseData['detail'];
          } else if (responseData.containsKey('non_field_errors')) {
            // Assuming 'non_field_errors' is a list
            if (responseData['non_field_errors'] is List) {
              errorMessage = (responseData['non_field_errors'] as List).join(' ');
            } else if (responseData['non_field_errors'] is String) {
              errorMessage = responseData['non_field_errors'];
            }
          } else if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMessage')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Handle network or parsing errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers when widget is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Assign form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Header Icon
                const Center(
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.grey),
                    hintText: "Enter your email",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType:
                      TextInputType.emailAddress, // Set to email input
                  autocorrect: false, // Disable autocorrect
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    }
                    // Email validation regex
                    final RegExp emailRegex = RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.grey),
                    hintText: "Enter your password",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context,
                          '/forgot-password'); // Navigate to Forgot Password
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Log In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A4FF3), // Purple
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("Log in"),
                  ),
                ),
                const SizedBox(height: 20),

                // Social Login (Optional)
                const Center(
                  child: Text(
                    "Or Login with",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      onPressed: () {
                        // Handle Facebook Login
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                      onPressed: () {
                        // Handle Google Login
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.apple, color: Colors.white),
                      onPressed: () {
                        // Handle Apple Login
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign-Up Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                      // Navigate to Sign-Up Page
                    },
                    child: const Text(
                      "Don’t have an account? Sign up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
