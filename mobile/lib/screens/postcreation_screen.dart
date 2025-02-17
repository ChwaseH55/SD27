import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:flutter/material.dart';

class PostCreationForm extends StatefulWidget {
  const PostCreationForm({super.key});

  static const routeName = '/extractIsUpdate';

  @override
  State<PostCreationForm> createState() => _PostCreationForm();
}

class _PostCreationForm extends State<PostCreationForm> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CreatePost());
  }
}

class CreatePost extends StatelessWidget {
  const CreatePost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: PostCreationWidget()),
      ),
    );
  }
}

class PostCreationWidget extends StatelessWidget {
  const PostCreationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CreateArgument;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              args.isUpdate ? 'Update Post' : 'Create New Post',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const PostForm(),
          ],
        ),
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  const PostForm({super.key});

  @override
  State<PostForm> createState() => _PostForm();
}

class _PostForm extends State<PostForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  CreateArgument? args; // Store argument for use in initState

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments only once
    final CreateArgument? receivedArgs =
        ModalRoute.of(context)?.settings.arguments as CreateArgument?;
    if (receivedArgs != null) {
      args = receivedArgs;
      titleController.text = args!.isUpdate ? args!.title : "";
      descriptionController.text = args!.isUpdate ? args!.content : "";
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Post Title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: args!.isUpdate ? 'Enter title' : 'New Post Title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 240, 235, 235),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Post Description',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 240, 235, 235),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (args!.isUpdate) {
                await updatePost(
                    postId: args!.postId.toString(),
                    title: titleController.text,
                    content: descriptionController.text);
                if (context.mounted) Navigator.of(context).pop();
              } else {
                String? id = await getUserID();
                await createPost(
                    title: titleController.text,
                    content: descriptionController.text,
                    userId: id);
               if (context.mounted) Navigator.pushNamed(context, '/pos');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: Text(args!.isUpdate ? 'Update' : 'Create Post',
                style: const TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
}
