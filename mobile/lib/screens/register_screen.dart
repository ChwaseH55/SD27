import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Color.fromRGBO(255, 204, 0, 1)],
          ),
        ),
        child: const Center(child: RegisterForm()),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterForm();
}

class _RegisterForm extends State<RegisterForm> {
  bool _isLoading = false;
  final userController = TextEditingController();
  final passController = TextEditingController();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    emailController.dispose();
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingAnimationWidget.threeArchedCircle(
            color: Colors.yellow, size: 100)
        : SingleChildScrollView(
          child: Card(
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
                    
                      // Welcome Text
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                     
                      Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          // Username Field
                          _buildTextField(userController, "First Name", false),
                          const SizedBox(height: 15),
                          // Password Field
                          _buildTextField(passController, "Last Name", false),
                          const SizedBox(height: 20),
                          _buildTextField(passController, "Email", false),
                          const SizedBox(height: 20),
                          _buildTextField(passController, "Username", false),
                          const SizedBox(height: 20),
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
                                    bool res = await registerUser(
                                    context: context,
                                    username: userController.text,
                                    password: passController.text,
                                    email: emailController.text,
                                    firstName: fnameController.text,
                                    lastName: lnameController.text
                                  );
                                    setState(
                                      () => _isLoading = false); // hide loading
                                    if (!res && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Invalid Registration Information')),
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
                          "Register",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                      const SizedBox(height: 15),
                      // Register Link
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: const Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: Color.fromRGBO(255, 204, 0, 1)),
                      ),
                    ),
                  ],
                ),
              ),
            )
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
