import 'package:flutter/material.dart';

class ForumCreationWidget extends StatelessWidget {

  const ForumCreationWidget(
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
        child: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text('Create New Forum',
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                    MyCustomForm()
                  ],
                ))));
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5,left: 10,right: 10,bottom: 10),
        child: Column(
        children: <Widget>[const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 34),
            child: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.bold))
          )
        ),
                        
          Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                  width: 300,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 5.0,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'name',
                    ),
                  ))),
                  const Align(
          alignment: Alignment.centerLeft,
          child: Text('Description',
                          style: TextStyle(fontWeight: FontWeight.bold))
        ),
          SingleChildScrollView(
            child: SizedBox(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      maxLines: 3, // Allow the text box to have multiple lines
                      textAlignVertical: TextAlignVertical.top,
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(
                            top: 10, bottom: 30, left: 5, right: 5),
                        border: OutlineInputBorder(),
                        hintText: 'description',
                      ),
                    ))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Change this value as needed
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            )
          )
        ]));
  }
}
