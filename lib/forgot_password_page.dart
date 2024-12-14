import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Back Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Navigate back
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),

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
                "Forgot password?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Text(
                "Don’t worry! It happens. Please enter the email associated with your account.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Email Field
              const TextField(
                decoration: InputDecoration(
                  labelText: "Email address",
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
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Send Code Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Send Code
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A4FF3), // Purple
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Send code"),
                ),
              ),
              const SizedBox(height: 20),

              // Log-In Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login'); // Navigate to Log-In Page
                  },
                  child: const Text(
                    "Remember password? Log in",
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
    );
  }
}