import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/auth_request.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UCF',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Username input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: userController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Username/Email',
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
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
                username: 'exampleUser',
                password: 'examplePass',
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

        //Password Forget btn
        TextButton(
          onPressed: () {},
          child: const Text(
            "Forget Password",
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),

        //Sign up btn
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/reg');
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
