import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:flutter/material.dart';

class PostCreationForm extends StatefulWidget {
  final bool isUpdate;
  final int postId;
  final String title;
  final String content;

  const PostCreationForm({
    super.key,
    required this.isUpdate,
    required this.postId,
    required this.title,
    required this.content,
  });

  static const routeName = '/extractUpdateInfo';

  @override
  State<PostCreationForm> createState() => _PostCreationForm();
}

class _PostCreationForm extends State<PostCreationForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreatePost(
        isUpdate: widget.isUpdate,
        postId: widget.postId,
        title: widget.title,
        content: widget.content,
      ),
    );
  }
}

class CreatePost extends StatelessWidget {
  final bool isUpdate;
  final int postId;
  final String title;
  final String content;

  const CreatePost({
    super.key,
    required this.isUpdate,
    required this.postId,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: isUpdate ? 'Edit Post' : 'Create Post', showBackButton: true,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: PostCreationWidget(
            isUpdate: isUpdate,
            postId: postId,
            title: title,
            content: content,
          ),
        ),
      ),
    );
  }
}

class PostCreationWidget extends StatelessWidget {
  final bool isUpdate;
  final int postId;
  final String title;
  final String content;

  const PostCreationWidget({
    super.key,
    required this.isUpdate,
    required this.postId,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              isUpdate ? 'Update Post' : 'Create New Post',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            PostForm(
              isUpdate: isUpdate,
              postId: postId,
              title: title,
              content: content,
            ),
          ],
        ),
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  final bool isUpdate;
  final int postId;
  final String title;
  final String content;

  const PostForm({
    super.key,
    required this.isUpdate,
    required this.postId,
    required this.title,
    required this.content,
  });

  @override
  State<PostForm> createState() => _PostForm();
}

class _PostForm extends State<PostForm> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.isUpdate ? widget.title : '');
    descriptionController =
        TextEditingController(text: widget.isUpdate ? widget.content : '');
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
          cursorColor: Colors.black,
          controller: titleController,
          decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide:
                BorderSide(color: Color.fromRGBO(186, 155, 55, 1), width: 2)),
            hintText: 'Enter title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          cursorColor: Colors.black,
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            
              focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide:
                BorderSide(color: Color.fromRGBO(186, 155, 55, 1), width: 2)),
            hintText: 'Enter description',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: const Color.fromARGB(255, 240, 235, 235),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (widget.isUpdate) {
                await updatePost(
                  postId: widget.postId.toString(),
                  title: titleController.text,
                  content: descriptionController.text,
                );
              } else {
                String? id = await getUserID();
                await createPost(
                  title: titleController.text,
                  content: descriptionController.text,
                  userId: id,
                );
              }
              if (context.mounted) Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: Text(widget.isUpdate ? 'Update' : 'Create Post',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
