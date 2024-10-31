import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  void handleClick(String value) {
    switch (value) {
      case 'Thing1':
        break;
      case 'Thing2':
        break;
    }
}

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const DrawerExample(),
    );
  }
}

class DrawerExample extends StatefulWidget {
  const DrawerExample({super.key});

  @override
  State<DrawerExample> createState() => _DrawerExampleState();
}

class _DrawerExampleState extends State<DrawerExample> {
  String selectedPage = '';

  @override
  Widget build(BuildContext context) {
    const appTitle = 'UCF';
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            appTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
        ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.65,
        height: MediaQuery.of(context).size.height * 1,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(
                height: 120,
                child:  DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Text(
                    'UCF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                     textAlign: TextAlign.center,
                  ),
                )
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Profile';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Discussion Form'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Discussion Form';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.set_meal),
                title: const Text('Payments'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Payments';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Calendar'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Calendar';
                  });
                },
              ),
               ListTile(
                leading: const Icon(Icons.videogame_asset),
                title: const Text('Tournaments'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Tournaments';
                  });
                },
              ),
               ListTile(
                leading: const Icon(Icons.align_vertical_bottom_rounded),
                title: const Text('Scores'),
                onTap: () {
                  setState(() {
                    selectedPage = 'Scores';
                  });
                },
              ),
            ],
          ),
        ),
      ),
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
        // Login Btn
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/mainMenu');
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
      ],
    );
  }
}
