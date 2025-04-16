import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserList();
}

class _UserList extends State<UserList> {
  late UserProvider userProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users',
            style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                labelText: 'Search Users',
                labelStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userprovider, child) {
                if (userprovider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredUsers =
                    userprovider.users.where((user) {
                  return user.username
                      .toLowerCase()
                      .contains(searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                      child: Text('No matching users found.'));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return InkWell(
                      onTap: () {
                        
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: UserWidget(
                        user: user ,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserWidget extends StatefulWidget {
  final UserModel user;

  const UserWidget({super.key, required this.user});

  @override
  State<UserWidget> createState() => _UserWidget();
}

class _UserWidget extends State<UserWidget> {
  @override
  Widget build(BuildContext context) {
    List<String> roles = [
      'Guest',
      'Member (Dues Not Paid)',
      'Member (Dues Paid)',
      'Coach',
      'Executive Board',
      'President'
    ];
   
    String role = roles[widget.user.roleid - 1];

    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
        child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: User info
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 5),
                            child: Text(
                              widget.user.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 20),
                            ),
                          ),
                          Text(widget.user.email),
                        ],
                      ),
                    ),

                    const SizedBox(width: 0),

                    // Right: Dropdown
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: role,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: roles.map((r) {
                          return DropdownMenuItem<String>(
                            value: r,
                            child: Text(r),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            role = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}



