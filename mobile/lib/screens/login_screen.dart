import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/auth_request.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35.0),
        child: AppBar(
          title: const Text(
            'UCF',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
        )
      ),
      body: const SingleChildScrollView(
        child: LoginForm()
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginForm();
}

// This class holds the data related to the Form.
class _LoginForm extends State<LoginForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final userController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
            height: height * 0.4,
            width: width * 0.4,
            child:
                const Image(image: AssetImage('assets/images/golf_logo.jpg'))),
        // Username input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextField(
              controller: userController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Username/Email',
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1),
                      width: 2.0), // Highlight color
                ),
              ),
            ),
          ),
        ),

        // Password input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Password',
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1),
                      width: 2.0), // Highlight color
                ),
              ),
            ),
          ),
        ),

        // Login Btn
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
          ),
          child: ElevatedButton(
            onPressed: () {
              loginUser(
                context: context,
                username: userController.text,
                password: passController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12), // Change this value as needed
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // //Password Forget btn
        // TextButton(
        //   onPressed: () {},
        //   child: const Text(
        //     "Forget Password",
        //     style: TextStyle(fontSize: 15, color: Colors.black),
        //   ),
        // ),

        // //Sign up btn
        // TextButton(
        //   onPressed: () {
        //     Navigator.pushNamed(context, '/reg');
        //   },
        //   child: const Text(
        //     "Sign Up",
        //     style: TextStyle(fontSize: 15, color: Colors.black),
        //   ),
        // ),
      ],
    );
  }
}
