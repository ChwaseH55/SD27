import 'dart:developer';
import 'package:bubble/bubble.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/chat_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/models/message_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async'; // Import for StreamSubscription

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Reference _storage = FirebaseStorage.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _chatNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingMessages = false;

  List<Chat> _chats = [];
  Chat? _activeChat;
  List<Message> _messages = [];
  List<UserModel> _selectedUsers = [];
  bool isEditMessage = false;
  bool _uploadingImage = false;
  List<UserModel> users = [];
  UserModel? _selectedUser;
  Message? _selectedMsg;

  StreamSubscription? _chatSubscription;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadChats();
    getUsers();
  }

  void getUsers() async {
    users = await getAllUsers();
  }

  void getSenderName() async {
    users = await getAllUsers();
  }

  void _loadChats() {
    _chatSubscription = _database.child('chats').onValue.listen((event) {
      if (!mounted) {
        return; // Ensure the widget is still in the tree before calling setState()
      }

      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> chatsData = event.snapshot.value as Map;
        final List<Chat> chats = [];

        try {
          chatsData.forEach((key, value) {
            if (value['participants'] != null &&
                value['participants'][widget.currentUserId] == true) {
              chats.add(Chat.fromJson(key, value));
            }
          });
        } catch (e) {
          log(e.toString());
        }

        if (mounted) {
          setState(() {
            _chats = chats;
          });
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    if (_activeChat == null) return;

    _messageSubscription?.cancel();

    _messageSubscription = _database
        .child('messages/${_activeChat!.id}')
        .orderByChild('timestamp')
        .onValue
        .listen((event) {
      if (!mounted) return;

      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> messagesData = event.snapshot.value as Map;
        final List<Message> messages = [];

        messagesData.forEach((key, value) {
          messages.add(Message.fromJson(key, value));
        });

        // 🔥 Sort messages by timestamp
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        if (mounted) {
          setState(() {
            _messages = messages;
            _isLoadingMessages = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel(); // Cancel Firebase listener
    _messageSubscription?.cancel(); // Cancel messages listener
    _messageController.dispose(); // Dispose text controller
    _scrollController.dispose(); // Dispose scroll controller
    _chatNameController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (isEditMessage) {
      _editMessage();
      isEditMessage = false;
      log(isEditMessage.toString());
      return;
    }
    final message = {
      'text': _messageController.text,
      'senderId': widget.currentUserId,
      'senderName': widget.currentUserName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    Map<dynamic, dynamic> lastMsg = {
      'text': _messageController.text,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };

    await _database.child('messages/${_activeChat!.id}').push().set(message);
    await _database
        .child('chats/${_activeChat!.id}')
        .update({'lastMessage': lastMsg});

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _editMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _database
        .child('messages/${_activeChat!.id}/${_selectedMsg!.id}')
        .update({
      'edited': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'text': _messageController.text
    });

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _createNewChat(bool isGroupChat) async {
    Map<String, bool> participants = {};
    final chat;
    if (_selectedUser == null && _selectedUsers == []) return;
    if (isGroupChat) {
      for (var user in _selectedUsers) {
        participants[user.id.toString()] = true;
      }
      chat = {
        'type': isGroupChat ? 'group' : 'direct',
        'createdBy': widget.currentUserId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'participants': participants,
        'name': _chatNameController.text
      };
    } else {
      participants = {
        widget.currentUserId: true,
        _selectedUser!.id.toString(): true
      };
      chat = {
        'type': isGroupChat ? 'group' : 'direct',
        'createdBy': widget.currentUserId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'participants': participants,
      };
    }

    await _database.child('chats').push().set(chat);

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _uploadingImage = true;
    });

    try {
      final ref = _storage.child(
          'chat_images/${_activeChat!.id}/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      final message = {
        'image': url,
        'senderId': widget.currentUserId,
        'senderName': widget.currentUserName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _database.child('messages/${_activeChat!.id}').push().set(message);
    } catch (e) {
      log('Error uploading image: $e');
    } finally {
      setState(() {
        _uploadingImage = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _activeChat == null ? _buildChatList() : _buildChatView(),
    );
  }

  Widget _buildChatList() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
          title: Text(_activeChat?.name ?? 'Chats'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  child: const Icon(Icons.add),
                  onTap: () {
                    // setState(() {
                    //   _showUserModal = true;
                    //   _isGroupChat = false;
                    //   _selectedUsers = [];
                    //   _groupName = '';
                    // });
                  },
                  onTapDown: (TapDownDetails details) {
                    _showPopupMenu(details.globalPosition);
                  },
                )),
          ],
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints(
              maxHeight: 500), // ✅ Prevents infinite height
          child: ListView.builder(
            itemCount: _chats.length,
            itemBuilder: (context, index) {
              final chat = _chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromRGBO(229, 191, 69, 1),
                  child: Text(
                    chat.name[0],
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                title: Text(chat.name),
                subtitle: Text(chat.lastMessage ?? 'No messages yet'),
                onTap: () async {
                  setState(() {
                    _activeChat = chat;
                    _messages = [];
                    _isLoadingMessages = true;
                  });
                  await _loadMessages();
                },
              );
            },
          ),
        ));
  }

  void _showMsgMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem(
          onTap: () {
            _messageController.text = _selectedMsg!.text!;
            isEditMessage = true;
            log(isEditMessage.toString());
          },
          value: 1,
          child: const Row(children: <Widget>[
            Icon(Icons.person_add),
            SizedBox(
              width: 5,
            ),
            Text("Edit Message")
          ]),
        ),
        PopupMenuItem(
          onTap: () {
            _deleteMsg();
          },
          value: 2,
          child: const Row(children: <Widget>[
            Icon(Icons.group_add_outlined),
            SizedBox(
              width: 5,
            ),
            Text("Delete Message")
          ]),
        )
      ],
      elevation: 8.0,
    ).then((value) {
      setState(() {});
    });
  }

  void _deleteMsg() async {
    await _database
        .child('messages/${_activeChat!.id}/${_selectedMsg!.id}')
        .remove();
  }

  void _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem(
          onTap: () => showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  // This setStateDialog is specific to the dialog
                  return AlertDialog(
                    title: const Text("Create Chat"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final isSelected = _selectedUser == user;
                              return InkWell(
                                onTap: () {
                                  setStateDialog(() {
                                    // Call setState inside dialog
                                    _selectedUser = user;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _userWidget(user, isSelected),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Closes the dialog
                        },
                        child: const Text("Close",
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () {
                          _createNewChat(false);
                        },
                        child: const Text("Create",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          value: 1,
          child: const Row(children: <Widget>[
            Icon(Icons.person_add),
            SizedBox(
              width: 5,
            ),
            Text("New Message")
          ]),
        ),
        PopupMenuItem(
          onTap: () => showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  // This setStateDialog is specific to the dialog
                  return AlertDialog(
                    title: const Text("Create Group Chat"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _chatNameController,
                          decoration: const InputDecoration(
                            hintText: 'Group Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final isSelected = _selectedUsers.contains(user);
                              return InkWell(
                                onTap: () {
                                  setStateDialog(() {
                                    if (isSelected) {
                                      _selectedUsers.remove(
                                          user); // Remove if already selected
                                    } else {
                                      _selectedUsers
                                          .add(user); // Add if not selected
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _userWidget(user, isSelected),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Closes the dialog
                        },
                        child: const Text("Close",
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () {
                          _createNewChat(true);
                          log('group chat creae');
                        },
                        child: const Text("Create",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          value: 1,
          child: const Row(children: <Widget>[
            Icon(Icons.group_add_outlined),
            SizedBox(
              width: 5,
            ),
            Text("Create Group")
          ]),
        )
      ],
      elevation: 8.0,
    ).then((value) {
      setState(() {
        _selectedUser = null;
        _selectedUsers = []; // Reset _selectedUser after dialog closes
      });
    });
  }

  Widget _userWidget(UserModel user, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Colors.yellow
                : Colors.black, // Highlight selected user
            width: 2.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 5),
                child: Row(
                  children: <Widget>[
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(user.email.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
          leading: GestureDetector(
            onTap: () {
              setState(() {
                _activeChat = null;

                _messages = []; // 🧹 Clear messages instantly
              });
              _loadChats();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Ensures minimal spacing
              children: [
                SizedBox(width: 14),
                Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 25), // Reduce size if needed
              ],
            ),
          ),
          title: Text(_activeChat?.name ?? 'Chats'),
        ),
        body: Column(
          children: [
            Expanded(
              // ✅ Constrains ListView
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoadingMessages
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe =
                                message.senderId == widget.currentUserId;
                            return GestureDetector(
                                onLongPressDown:
                                    (LongPressDownDetails details) {
                                  _selectedMsg = message;
                                  _showMsgMenu(details.globalPosition);
                                },
                                child: Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: Bubble(
                                      padding: const BubbleEdges.all(
                                          0), // remove internal padding from Bubble
                                      elevation: 5,
                                      margin: const BubbleEdges.symmetric(
                                          horizontal: 0, vertical: 2),
                                      color: Colors
                                          .transparent, // make bubble itself transparent
                                      nip: isMe
                                          ? BubbleNip.rightBottom
                                          : BubbleNip.leftBottom,
                                      child: Container(
                                        padding: const EdgeInsets.all(11),
                                        decoration: BoxDecoration(
                                          gradient: isMe
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color.fromRGBO(
                                                        229, 191, 69, 1),
                                                    Color.fromRGBO(
                                                        137, 108, 14, 1)
                                                  ],
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                )
                                              : null,
                                          color: isMe
                                              ? null
                                              : Colors.grey[
                                                  300], // fallback for non-gradient
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!isMe)
                                              Text(
                                                message.senderName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            if (message.imageUrl != null)
                                              Image.network(
                                                message.imageUrl!,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            if (message.text != null)
                                              Text(
                                                message.text!,
                                                style: TextStyle(
                                                  color: isMe
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            Text(
                                              DateFormat('hh:mm a').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        message.timestamp),
                                              ),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isMe
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        )),
            ),
            _buildMessageInput(), // ✅ Ensures input field is placed correctly
          ],
        ));
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _uploadingImage ? null : _uploadImage,
          ),
          Expanded(
            child: TextField(
              cursorColor: const Color.fromRGBO(186, 155, 55, 1),
              controller: _messageController,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(186, 155, 55, 1), width: 2)),
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
