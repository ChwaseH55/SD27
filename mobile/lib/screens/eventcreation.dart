import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/arguments/eventcreateargument.dart';
import 'package:flutter/material.dart';

class CreateEvent extends StatelessWidget {
  const CreateEvent({super.key});

  static const routeName = '/extractEventInfo';

  @override
  Widget build(BuildContext context) {
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
          'Create Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: EventCreationWidget(),
      ),
    );
  }
}

class EventCreationWidget extends StatefulWidget {
  const EventCreationWidget({super.key});

  @override
  State<EventCreationWidget> createState() => _EventCreationWidgetState();
}

class _EventCreationWidgetState extends State<EventCreationWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final titleFocusNode = FocusNode();
  final locationFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final typeFocusNode = FocusNode();
  final registerFocusNode = FocusNode();
  DateTime? selectedDate;
  bool requiresRegistration = false; // Checkbox state
  EventCreateArgument? args; // Store argument for use in initState

  bool _initialized = false; // Prevents resetting user input

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Ensure values are set only once
      final EventCreateArgument? receivedArgs =
          ModalRoute.of(context)?.settings.arguments as EventCreateArgument?;
      if (receivedArgs != null && receivedArgs.isUpdate) {
        args = receivedArgs;
        titleController.text = args!.title;
        descriptionController.text = args!.content;
        locationController.text = args!.location;
        eventTypeController.text = args!.type;
        requiresRegistration = args!.registration;
        selectedDate = DateTime.parse(args!.date);
      }
      _initialized = true; // Prevent future resets
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    eventTypeController.dispose();
    titleFocusNode.dispose();
    locationFocusNode.dispose();
    descriptionFocusNode.dispose();
    typeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as EventCreateArgument;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                args.isUpdate ? 'Update Event' : 'Create New Event',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Event Title
            const Text('Event Title',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              focusNode: titleFocusNode,
              controller: titleController,
              decoration: _inputDecoration('Enter event title'),
            ),
            const SizedBox(height: 15),

            // Event Location
            const Text('Event Location',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              focusNode: locationFocusNode,
              controller: locationController,
              decoration: _inputDecoration('Enter event location'),
            ),
            const SizedBox(height: 15),

            // Event Date Picker
            const Text('Event Date',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: _inputDecoration(selectedDate == null
                      ? 'Select event date'
                      : "${selectedDate!.toLocal()}".split(' ')[0]),
                ),
              ),
            ),
            const SizedBox(height: 15),

            const Text('Event Type',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              focusNode: typeFocusNode,
              controller: eventTypeController,
              decoration: _inputDecoration('Enter event type'),
            ),
            const SizedBox(height: 15),

            // Event Description
            const Text('Event Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              focusNode: descriptionFocusNode,
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration('Enter event description'),
            ),

            // Registration Checkbox
            CheckboxListTile(
              focusNode: registerFocusNode,
              title: const Text('Requires Registration'),
              value: requiresRegistration,
              onChanged: (bool? value) {
                setState(() {
                  requiresRegistration = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color.fromRGBO(186, 155, 55, 1),
            ),

            // Create Event Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (args.isUpdate) {
                    await updateEvent(
                        args.eventId,
                        titleController.text,
                        descriptionController.text,
                        selectedDate.toString(),
                        eventTypeController.text);
                  } else {
                    String? id = await getUserID();
                    await createEvent(
                      titleController.text,
                      selectedDate.toString(),
                      locationController.text,
                      eventTypeController.text,
                      requiresRegistration,
                      int.parse(id!),
                      descriptionController.text,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  args.isUpdate ? 'Update Event' : 'Create Event',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
    );
  }
}
