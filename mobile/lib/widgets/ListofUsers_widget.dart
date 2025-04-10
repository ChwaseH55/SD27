import 'dart:developer';

import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

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
    log('${widget.user.roleid}');
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
