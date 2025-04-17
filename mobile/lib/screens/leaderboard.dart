import 'dart:developer';

import 'package:coffee_card/api_request/scores_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/scores_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StepLeaderboardScreen extends StatefulWidget {
  final String event;
  const StepLeaderboardScreen({super.key, required this.event});

  @override
  State<StepLeaderboardScreen> createState() => _StepLeaderboardScreenState();
}

class _StepLeaderboardScreenState extends State<StepLeaderboardScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  List<ScoresModel>? _scores;
  List<ScoresModel>? tempScores = [
    ScoresModel(userid: 1, score: 23),
    ScoresModel(userid: 1, score: 33),
    ScoresModel(userid: 1, score: 3)
  ];
  Map<int, UserModel>? names = {};
  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   if (_isInit) {
  //     _isLoading = true;
  //     await getAllScores().then((scores) {
  //       if (mounted) {
  //         setState(() {
  //           _scores = scores;
  //           _isLoading = false;
  //         });
  //       }
  //     });
  //     for (var n in tempScores!) {
  //       await getSingleUser(userId: '${n.userid}').then((user) {
  //         if (mounted) {
  //           setState(() {
  //             names![n.userid!] = user;
  //             _isLoading = false;
  //           });
  //         }
  //       });
  //     }

  //     _isInit = false;
  //   }
  // }

 @override
  void initState() {
    super.initState();
    getUnis();
  }

  void getUnis() async {
     Map<int,UserModel> fetchedUsers = {};
    for (var n in tempScores!) {
        fetchedUsers[n.userid!] = await getSingleUser(userId: '${n.userid}');
      }
 
    setState(() {
      names = fetchedUsers;
    });
  }

  bool showAvgSteps = true;

  @override
  Widget build(BuildContext context) {
    log('$tempScores');
    log('$names');
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(
        title: 'Leader Board',
        showBackButton: true,
      ),
      body: Column(
              children: [
                // Header with trophy and title
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  color: const Color.fromRGBO(186, 155, 55, 1),
                  child: Column(
                    children: [
                      trophyHeader(),
                      const SizedBox(height: 8),
                      Text(
                        widget.event,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton("avg. steps", showAvgSteps, () {
                        setState(() => showAvgSteps = true);
                      }),
                      _buildToggleButton("7day steps", !showAvgSteps, () {
                        setState(() => showAvgSteps = false);
                      }),
                    ],
                  ),
                ),

                // Leaderboard list
                Expanded(
                  child: ListView.builder(
                    itemCount: tempScores!.length,
                    itemBuilder: (context, index) {
                      final score = tempScores![index];
                      
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Stack(
                            children: [
                              // The main ListTile
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                                    child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(229, 191, 69, 1),
                          Color.fromRGBO(137, 108, 14, 1)
                        ],
                      ),
                    ),
                    child: names![score.userid]!.profilepicture == null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              names![score.userid]!.username.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                        : CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(names![score.userid]!.profilepicture!),
                          ),
                  ),
                                  ),
                                  title: names!.containsKey(score.userid)
                                      ? Text(names![score.userid]!.username)
                                      : const Text("Loading..."),
                                  subtitle: Text('Score: ${score.score}'),
                                  trailing: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: _getRankColor(index),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                              // Star icons in corners
                              Positioned(
                                top: 48,
                                left: 16,
                                child: Icon(Icons.star,
                                    size: 30, color: _getRankColor(index)),
                              ),
                            ],
                          ));
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            //color: isActive ? Colors.teal[800] : Colors.teal[100],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Color _getRankColor(int index) {
  switch (index) {
    case 0:
      return Colors.yellow;
    case 1:
      return Colors.grey;
    case 2:
      return Colors.amber;
    default:
      return Colors.black;
  }
}

Widget trophyHeader() {
  return Container(
    width: double.infinity,
    height: 120,
    color: const Color.fromRGBO(186, 155, 55, 1),
    child: const Stack(
      alignment: Alignment.center,
      children: [
        // Trophy Icon
        Icon(
          Icons.emoji_events,
          size: 100,
          color: Colors.orange,
        ),

        // Sparkles around
        Positioned(
          top: 30,
          left: 165,
          child: Icon(Icons.star, size: 30, color: Color.fromARGB(255, 255, 188, 43)),
        ),
        
      ],
    ),
  );
}
