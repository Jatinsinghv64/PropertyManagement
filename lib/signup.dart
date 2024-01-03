import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xFF013c7e),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SignUpForm(),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        Text(
          'Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            // Create a new user account
            try {
              await _auth.createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
              );
            } catch (e) {
              print('Error signing up: $e');
              // Handle sign-up errors
            }
          },
          child: Text('Sign Up'),
        ),
      ],
    );
  }
}