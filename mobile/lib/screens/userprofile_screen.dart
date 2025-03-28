import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:coffee_card/screens/event_info.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
import 'package:coffee_card/utils.dart';
import 'package:coffee_card/widgets/events_widgets.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {
  late UserProvider userProvider;
  final nameController = TextEditingController();
  final userNameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getUsers();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    List<String> role = ['One', 'Two', 'Three', 'Four', 'Five'];

    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Ensures minimal spacing
              children: [
                SizedBox(width: 14),
                Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 16), // Reduce size if needed

                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          title: const Text(
            'Your Account',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: TextButton(
                onPressed: () async {
                  logoutUser();
                  Navigator.pushReplacementNamed(context, '/');
                },
                
                child:
                    const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900), ),
              )
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(4),
                child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                  if (userProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  ImageProvider<Object>? picture;
                  if(userProvider.user!.profilepicture == null) {
                    picture = const AssetImage('assets/images/golf_logo.jpg');
                  } else {
                    picture = NetworkImage(userProvider.user!.profilepicture!);
                  }
                  return Card(
                      elevation: 4,
                      child: SizedBox(
                          child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        'Welcome ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900),
                                      ),
                                      Text(userProvider.user!.username)
                                    ],
                                  ),
                                  Text(role.elementAt(
                                      userProvider.user!.roleid - 1)),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundImage: picture,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Upload Picture",
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(186, 155, 55, 1)),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Name: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900)),
                                      Text(userProvider.user!.firstname!),
                                      Text(userProvider.user!.lastname!)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Email: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900)),
                                      Text(userProvider.user!.email),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(186, 155, 55, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // Change this value as needed
                                      ),
                                    ),
                                    child: const Text(
                                      'Change Name',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(186, 155, 55, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // Change this value as needed
                                      ),
                                    ),
                                    child: const Text(
                                      'Change Username',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text('Your Registered Events:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  color: Color.fromRGBO(
                                                      186, 155, 55, 1))))),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: SizedBox(
                                            height: height * 0.5,
                                            child: Column(children: <Widget>[
                                              Expanded(
                                                child: Consumer<EventsProvider>(
                                                  builder: (context,
                                                      eventsProvider, child) {
                                                    if (eventsProvider
                                                        .isLoading) {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    }
                                                    final eventsList =
                                                        eventsProvider
                                                            .registeredevents;
                                                    return ListView.builder(
                                                      itemCount:
                                                          eventsList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final event =
                                                            eventsList[index];
                                                        return InkWell(
                                                          onTap: () async {
                                                            await Navigator.pushNamed(
                                                                context,
                                                                EventsListScreen
                                                                    .routeName,
                                                                arguments:
                                                                    IsAllOrReg(
                                                                        false));
                                                          },
                                                          child:
                                                              UserEventsWidgets(
                                                            isReg: eventsProvider
                                                                    .isRegList[
                                                                event.eventid],
                                                            event: event,
                                                            userId:
                                                                eventsProvider
                                                                    .userId,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              )
                                            ])),
                                      )
                                    ],
                                  ),
                                ],
                              ))));
                }))
          ],
        )));
  }
}

class UserEventsWidgets extends StatefulWidget {
  final bool? isReg;
  final EventsModel event;
  final String? userId;

  const UserEventsWidgets({
    super.key,
    required this.isReg,
    required this.event,
    required this.userId,
  });

  @override
  State<UserEventsWidgets> createState() {
    return _UserEventsWidgets();
  }
}

class _UserEventsWidgets extends State<UserEventsWidgets> {
  late EventsProvider eventsProvider =
      eventsProvider = Provider.of<EventsProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM d, yyyy')
        .format(DateTime.parse(widget.event.eventdate!));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.event.eventname!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.event.eventdescription!,
                style: const TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
