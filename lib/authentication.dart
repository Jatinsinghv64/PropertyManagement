import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:property/profile.dart';
import 'package:property/signup.dart';
import 'package:provider/provider.dart';

class AuthenticationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFF013c7e),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
            // Sign in with email and password
            try {
              await _auth.signInWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
              );

              // Show a Snackbar upon successful login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully logged in!'),
                  duration: Duration(seconds: 4),
                ),
              );

              // Navigate to the ProfilePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            } catch (e) {
              print('Error signing in: $e');
              // Handle sign-in errors
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF013c7e), // Set background color here
          ),
          child: Text('Sign In'),
        ),

        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?"),
            TextButton(
              onPressed: () {
                // Navigate to the sign-up page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ],
    );
  }
}



