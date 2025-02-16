import 'dart:convert';

import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/landing/verfiy_otp.dart';
import 'package:blogs_app/sheets/login_sheet.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterSheet extends StatefulWidget {
  const RegisterSheet({super.key});

  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureText2 = true;

  // Controllers to manage text input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }


  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      postData(_nameController.text, _emailController.text,
          _passwordController.text, context);
    }
  }

  // void _onSignUpComplete() {
  //   Navigator.of(context).pop();
  //   Navigator.of(context).push(MaterialPageRoute(
  //       builder: (ctx) => VerifyOtp(
  //             email: _emailController.text,
  //           )));
  //   // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //   //   content: Text('Registerd Successfully, Login with the same credentials!'),
  //   // ));
  // }

  Future<void> postData(
      String name, String email, String password, BuildContext context) async {
    showLoadingDialog(context, 'Verifying Details...');
    final url = Uri.parse('${Constants.uri}signup');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body =
        json.encode({"fullName": name, "email": email, "password": password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => VerifyOtp(
                  email: email,
                  name: name,
                  password: password,
                )));
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      Navigator.of(context).pop();
      showSnackBar(context, 'Error verifying details!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        color: Color(0xFFFFECAA),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to VerseVibe!',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'Register',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red)),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              const Align(
                alignment: Alignment.topLeft,
                child: Text('Full Name'),
              ),
              SizedBox(height: screenHeight * 0.005),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  hintStyle: const TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // You can add more validation logic here, like email format validation
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              const Align(
                alignment: Alignment.topLeft,
                child: Text('Username/Email'),
              ),
              SizedBox(height: screenHeight * 0.005),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'info@example.com',
                  hintStyle: const TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  // You can add more validation logic here, like email format validation
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025,
                    horizontal: screenWidth * 0.04,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: _togglePasswordView,
                  ),
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.black),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                  final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                  final hasSpecialChar =
                      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);

                  if (!hasLetter || !hasNumber || !hasSpecialChar) {
                    return 'Password should contain letters, numbers, and special characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureText2,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025,
                    horizontal: screenWidth * 0.04,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText2 ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: _toggleConfirmPasswordView,
                  ),
                  hintText: 'Confirm Password',
                  hintStyle: const TextStyle(color: Colors.black),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                ),
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
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.075,
                child: TextButton(
                  onPressed: _register,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFDE69),
                    backgroundColor: const Color(0xFF050522),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFFFFECAA),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(48),
                                    topRight: Radius.circular(48))),
                            builder: (ctx) => const LoginSheet(),
                            isScrollControlled: true);
                      },
                      child: const Text('Login',
                          style: TextStyle(fontSize: 16, color: Colors.red))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
