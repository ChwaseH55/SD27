import 'dart:developer';

import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.getUsers();
    });
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

    return Scaffold(
        appBar: CustomAppBar(
          title: 'Your Account',
          showBackButton: true,
          actions: [
            TextButton.icon(
              onPressed: () async {
                logoutUser();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(
                Icons.logout,
                size: 20,
                color: Colors.red,
              ),
              label: const Text(
                'Log out',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
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
                    return Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                          color: Colors.black, size: 100),
                    );
                  }

                  ImageProvider<Object>? picture;
                  if (userProvider.user == null) {
                    return const Center(
                        child: Text('Error getting profile information'));
                  } else if (userProvider.user!.profilepicture == null) {
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
                                      EditableWelcomeText(
                                          initialText:
                                              userProvider.user!.username,
                                          user: userProvider.user!),
                                    ],
                                  ),
                                  Text(
                                      'Membership Status: ${_getRoleName(userProvider.user!.roleid)}'),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromRGBO(229, 191, 69, 1),
                                          Color.fromRGBO(137, 108, 14, 1)
                                        ],
                                      ),
                                    ),
                                    child: userProvider.user!.profilepicture ==
                                            null
                                        ? CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.transparent,
                                            child: Text(
                                              '${userProvider.user!.firstname![0].toUpperCase()}${userProvider.user!.lastname![0].toUpperCase()}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ))
                                        : CircleAvatar(
                                            radius: 25,
                                            backgroundImage: picture,
                                          ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform
                                              .pickFiles(allowMultiple: true);

                                      await updateUserInfo(
                                          null, null, null, result,
                                          id: userProvider.user!.id.toString());
                                    },
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
                                      Text(
                                          'Name: ${userProvider.user!.firstname!} ${userProvider.user!.lastname!}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900)),
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
                                  const SizedBox(
                                    height: 18,
                                  )
                                  // const Align(
                                  //     alignment: Alignment.centerLeft,
                                  //     child: Padding(
                                  //         padding: EdgeInsets.only(left: 10),
                                  //         child: Text('Your Registered Events:',
                                  //             style: TextStyle(
                                  //                 fontWeight: FontWeight.w900,
                                  //                 color: Color.fromRGBO(
                                  //                     186, 155, 55, 1))))),
                                  // Column(
                                  //   children: <Widget>[
                                  //     Container(
                                  //       decoration: BoxDecoration(
                                  //         color: Colors.grey,
                                  //         borderRadius:
                                  //             BorderRadius.circular(30),
                                  //       ),
                                  //       child: SizedBox(
                                  //           height: height * 0.5,
                                  //           child: Column(children: <Widget>[
                                  //             Expanded(
                                  //               child: Consumer<EventsProvider>(
                                  //                 builder: (context,
                                  //                     eventsProvider, child) {
                                  //                   if (eventsProvider
                                  //                       .isLoading) {
                                  //                     return const Center(
                                  //                         child:
                                  //                             CircularProgressIndicator());
                                  //                   }
                                  //                   final eventsList =
                                  //                       eventsProvider
                                  //                           .registeredevents;
                                  //                   return ListView.builder(
                                  //                     itemCount:
                                  //                         eventsList.length,
                                  //                     itemBuilder:
                                  //                         (context, index) {
                                  //                       final event =
                                  //                           eventsList[index];
                                  //                       return InkWell(
                                  //                         onTap: () async {
                                  //                           await Navigator.pushNamed(
                                  //                               context,
                                  //                               EventsListScreen
                                  //                                   .routeName,
                                  //                               arguments:
                                  //                                   IsAllOrReg(
                                  //                                       false));
                                  //                         },
                                  //                         child:
                                  //                             UserEventsWidgets(
                                  //                           isReg: eventsProvider
                                  //                                   .isRegList[
                                  //                               event.eventid],
                                  //                           event: event,
                                  //                           userId:
                                  //                               eventsProvider
                                  //                                   .userId,
                                  //                         ),
                                  //                       );
                                  //                     },
                                  //                   );
                                  //                 },
                                  //               ),
                                  //             )
                                  //           ])),
                                  //     )
                                  //   ],
                                  // ),
                                ],
                              ))));
                }))
          ],
        )));
  }
}

class EditableWelcomeText extends StatefulWidget {
  final String initialText;
  final UserModel user;

  const EditableWelcomeText(
      {super.key, required this.initialText, required this.user});

  @override
  State<EditableWelcomeText> createState() => _EditableWelcomeTextState();
}

class _EditableWelcomeTextState extends State<EditableWelcomeText> {
  bool isEditing = false;
  late TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min, // this makes the row shrink-wrap its content
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        isEditing
            ? Flexible(
                child: SizedBox(
                  width: 200, // set a finite width
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              )
            : Text(
                'Welcome ${_controller.text}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: () async {
            if (isEditing) {
              await updateUserInfo(
                  id: widget.user.id.toString(),
                  _controller.text,
                  null,
                  null,
                  null);
            }
            setState(() {
              isEditing = !isEditing;
            });
          },
        ),
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          )
      ],
    );
  }
}

//class UserEventsWidgets extends StatefulWidget {
//   final bool? isReg;
//   final EventsModel event;
//   final String? userId;

//   const UserEventsWidgets({
//     super.key,
//     required this.isReg,
//     required this.event,
//     required this.userId,
//   });

//   @override
//   State<UserEventsWidgets> createState() {
//     return _UserEventsWidgets();
//   }
// }

// class _UserEventsWidgets extends State<UserEventsWidgets> {
//   late EventsProvider eventsProvider =
//       eventsProvider = Provider.of<EventsProvider>(context, listen: false);

//   @override
//   Widget build(BuildContext context) {
//     String formattedDate = DateFormat('MMM d, yyyy')
//         .format(DateTime.parse(widget.event.eventdate!));
//     double width = MediaQuery.sizeOf(context).width;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Text(
//                       widget.event.eventname!,
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     formattedDate,
//                     style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 widget.event.eventdescription!,
//                 style: const TextStyle(fontSize: 16, height: 1.4),
//                 textAlign: TextAlign.justify,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

String _getRoleName(int roleId) {
  switch (roleId) {
    case 1:
      return 'Guest';
    case 2:
      return 'Member (Dues Not Paid)';
    case 3:
      return 'Member (Dues Paid)';
    case 4:
      return 'Coach';
    case 5:
      return 'Executive Board';
    case 6:
      return 'President';
    default:
      return 'Unknown';
  }
}
