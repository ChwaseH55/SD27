import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final StorageReference _storage = FirebaseStorage.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Chat> _chats = [];
  Chat? _activeChat;
  List<Message> _messages = [];
  bool _isGroupChat = false;
  String _groupName = '';
  List<User> _selectedUsers = [];
  List<User> _availableUsers = [];
  bool _showUserModal = false;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    _database.child('chats').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> chatsData = event.snapshot.value as Map;
        final List<Chat> chats = [];

        chatsData.forEach((key, value) {
          if (value['participants'] != null &&
              value['participants'][widget.currentUserId] == true) {
            chats.add(Chat.fromJson(key, value));
          }
        });

        setState(() {
          _chats = chats;
        });
      }
    });
  }

  void _loadMessages() {
    if (_activeChat == null) return;

    _database
        .child('messages/${_activeChat!.id}')
        .orderByChild('timestamp')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> messagesData = event.snapshot.value as Map;
        final List<Message> messages = [];

        messagesData.forEach((key, value) {
          messages.add(Message.fromJson(key, value));
        });

        setState(() {
          _messages = messages;
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'text': _messageController.text,
      'senderId': widget.currentUserId,
      'senderName': widget.currentUserName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await _database
        .child('messages/${_activeChat!.id}')
        .push()
        .set(message);

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
      final ref = _storage
          .child('chat_images/${_activeChat!.id}/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      final message = {
        'imageUrl': url,
        'senderId': widget.currentUserId,
        'senderName': widget.currentUserName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _database
          .child('messages/${_activeChat!.id}')
          .push()
          .set(message);
    } catch (e) {
      print('Error uploading image: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_activeChat?.name ?? 'Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _showUserModal = true;
                _isGroupChat = false;
                _selectedUsers = [];
                _groupName = '';
              });
            },
          ),
        ],
      ),
      body: _activeChat == null
          ? _buildChatList()
          : _buildChatView(),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(chat.name[0]),
          ),
          title: Text(chat.name),
          subtitle: Text(chat.lastMessage ?? 'No messages yet'),
          onTap: () {
            setState(() {
              _activeChat = chat;
            });
            _loadMessages();
          },
        );
      },
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isMe = message.senderId == widget.currentUserId;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      Text(
                        DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(message.timestamp),
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
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
              controller: _messageController,
              decoration: const InputDecoration(
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

class Chat {
  final String id;
  final String name;
  final String type;
  final Map<String, bool> participants;
  final String? lastMessage;

  Chat({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    this.lastMessage,
  });

  factory Chat.fromJson(String id, Map<dynamic, dynamic> json) {
    return Chat(
      id: id,
      name: json['name'] ?? 'Chat',
      type: json['type'] ?? 'direct',
      participants: Map<String, bool>.from(json['participants'] ?? {}),
      lastMessage: json['lastMessage'],
    );
  }
}

class Message {
  final String id;
  final String? text;
  final String? imageUrl;
  final String senderId;
  final String senderName;
  final int timestamp;

  Message({
    required this.id,
    this.text,
    this.imageUrl,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory Message.fromJson(String id, Map<dynamic, dynamic> json) {
    return Message(
      id: id,
      text: json['text'],
      imageUrl: json['imageUrl'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      timestamp: json['timestamp'],
    );
  }
}

class User {
  final String id;
  final String username;
  final String? firstname;
  final String? lastname;

  User({
    required this.id,
    required this.username,
    this.firstname,
    this.lastname,
  });
} 