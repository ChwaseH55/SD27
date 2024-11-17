import 'package:flutter/material.dart';

class AnnouncementCreationScreen extends StatelessWidget {
  const AnnouncementCreationScreen({super.key});

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
      body: const AnnouncementForm(),
    );
  }
}

class AnnouncementForm extends StatefulWidget {
  const AnnouncementForm({super.key});

  @override
  State<AnnouncementForm> createState() => _AnnouncementForm();
}

// This class holds the data related to the Announcement Form.
class _AnnouncementForm extends State<AnnouncementForm> {
  final announcementName = TextEditingController();
  final announcementMessage = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    announcementName.dispose();
    announcementMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
    padding: EdgeInsets.only(right: screenWidth * 0.04, left: screenWidth * 0.04),
      child: SizedBox(
        height: screenHeight * 0.75,
        child: Card(
          elevation: 50,
          child: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  //Announcement Title Section
                  const Text(
                    'Title',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextField(
                        controller: announcementName,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Announcement Title',
                        ),
                      ),
                    ),
                  ),

                  //Announcement Message Section
                  const Text(
                    'Message Body',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextField(
                        controller: announcementMessage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Message',
                        ),
                      ),
                    ),
                  ),

                  //Announcement Role Section
                  const Text(
                    'Roles',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const DropdownMenu(
                      hintText: "Select Role",
                      dropdownMenuEntries: <DropdownMenuEntry>[
                        DropdownMenuEntry(value: 'Member', label: 'Member'),
                        DropdownMenuEntry(value: 'Coach', label: 'Coach'),
                        DropdownMenuEntry(value: 'Executive', label: 'Executive'),
                      ]),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                    ),

                    //Announcement Create Btn Section
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                          side: const BorderSide(
                            width: 2.0,
                            color: Colors.black,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Change this value as needed
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
                    ),
                  ),
                ],
              ))
        )
      )
    );
  }
}
