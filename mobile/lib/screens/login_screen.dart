import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Color.fromRGBO(255, 204, 0, 1)],
          ),
        ),
        child: const Center(child: LoginForm()),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;
  final userController = TextEditingController();
  final passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingAnimationWidget.threeArchedCircle(
            color: Colors.yellow, size: 100)
        : Card(
            elevation: 5,
            color: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/golf_logo.jpg'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 15),

                  // Welcome Text
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),

                  const Text(
                    "Log in to continue to your dashboard",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        // Username Field
                        _buildTextField(userController, "Username", false),
                        const SizedBox(height: 15),
                        // Password Field
                        _buildTextField(passController, "Password", true),
                        const SizedBox(height: 20),
                      ])),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null // disable button during loading
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(
                                    () => _isLoading = true); // show loading

                                bool res = await loginUser(
                                  context: context,
                                  username: userController.text,
                                  password: passController.text,
                                );

                                setState(
                                    () => _isLoading = false); // hide loading

                                if (!res && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Invalid Username or Password')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 204, 0, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Register Link
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/reg');
                    },
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Color.fromRGBO(255, 204, 0, 1)),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, bool obscure) {
    return TextFormField(
      cursorColor: const Color.fromRGBO(186, 155, 55, 1),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide:
                BorderSide(color: Color.fromRGBO(186, 155, 55, 1), width: 2)),
        filled: true,
        fillColor: Colors.white10,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
