import 'package:flutter/material.dart';
import 'package:nyampah_app/screens/signup/signup_screen.dart';
import 'package:nyampah_app/main.dart';
import 'package:nyampah_app/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisibility = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF5F4ED),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double scale = constraints.maxWidth / 375;
              double buttonWidth = constraints.maxWidth * 0.9;
              return Align(
                alignment: AlignmentDirectional.topCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 25 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome To Nyampah!',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF00693E),
                                  fontSize: 30 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Please sign in first',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF00693E),
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            buildInputField(
                              context,
                              label: 'Email',
                              controller: emailController,
                              scale: scale,
                            ),
                            SizedBox(height: 20 * scale),
                            buildInputField(
                              context,
                              label: 'Password',
                              controller: passwordController,
                              isPassword: true,
                              passwordVisibility: passwordVisibility,
                              onVisibilityToggle: () {
                                setState(() {
                                  passwordVisibility = !passwordVisibility;
                                });
                              },
                              scale: scale,
                            ),
                          ],
                        ),
                        SizedBox(height: 20 * scale),
                        _isLoading
                            ? CircularProgressIndicator(
                                color: const Color(0xFF00693E),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  final email = emailController.text.trim();
                                  final password = passwordController.text;

                                  if (email.isEmpty || password.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text('Please fill in all fields'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  if (password.length < 8) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFFF5F4ED),
                                        title: const Text('Error'),
                                        content: const Text('Password harus minimal memiliki 8 karakter'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(color: Color(0xFFFF8302)),
                                            ),
                                            ),
                                        ],
                                      ),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  try {
                                    final response = await UserService.loginUser(email, password);

                                    final prefs = await SharedPreferences.getInstance();
                                    final user = response['data']['user'];
                                    final token = response['data']['token'];

                                    await prefs.setString('user', jsonEncode(user));
                                    await prefs.setString('token', token);
                                    await prefs.setBool('isLogin', true);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Login successful!')),
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MainNavigator()),
                                    );
                                  } catch (error) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFFF5F4ED),
                                        title: const Text('Login Failed'),
                                        content: const Text('Email atau Password salah'),
                                        actions: [
                                            TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(color: Color(0xFFFF8302)),
                                            ),
                                            ),
                                        ],
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00693E),
                                  minimumSize: Size(buttonWidth, 48 * scale),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0 * scale,
                                    vertical: 12.0 * scale,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0 * scale),
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.white,
                                    fontSize: 15 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        SizedBox(height: 20 * scale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Dont have an account?',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: const Color(0xFF00693E),
                                fontSize: 14 * scale,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()));
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFFFF8302),
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool passwordVisibility = false,
    VoidCallback? onVisibilityToggle,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: const Color(0xFF00693E),
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2 * scale),
        TextField(
          controller: controller,
          obscureText: isPassword && !passwordVisibility,
          cursorColor: const Color(0xFF00693E), // Set cursor color to green
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xFF00693E),
                width: 0.5 * scale,
              ),
              borderRadius: BorderRadius.circular(8.0 * scale),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xFF00693E),
                width: 0.5 * scale,
              ),
              borderRadius: BorderRadius.circular(8.0 * scale),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      passwordVisibility
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 22 * scale,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
          style: TextStyle(
            fontFamily: 'Inter',
            color: const Color(0xFF00693E),
            fontSize: 14 * scale,
          ),
        ),
      ],
    );
  }
}
