import 'dart:developer';

import 'package:coffee_card/api_request/scores_request.dart';
import 'package:coffee_card/models/custom_scores_model.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/providers/scores_approval_provider.dart';

class ScoreListScreen extends StatefulWidget {
  const ScoreListScreen({super.key});

  @override
  State<ScoreListScreen> createState() => _ScoreListScreen();
}

class _ScoreListScreen extends State<ScoreListScreen> {
  String scoreType = 'all';
  String value = '';
  late ScoresAdminProvider _scoresProvider;

  @override
  void initState() {
    super.initState();
    _scoresProvider = ScoresAdminProvider(scoreType, value);
  }

  @override
  void dispose() {
    _scoresProvider.dispose();
    super.dispose();
  }

  void _updateSelectedWidget(String state, {String newValue = ''}) {
    setState(() {
      scoreType = state;
      value = newValue;

      // Recreate the provider when values change
      _scoresProvider.dispose(); // Dispose old one
      _scoresProvider = ScoresAdminProvider(scoreType, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Score Approval',
        showBackButton: true,
      ),
      body: ChangeNotifierProvider<ScoresAdminProvider>.value(
        value: _scoresProvider,
        child: ScoresWidget(scoreState: scoreType, value: value),
      ),
    );
  }
}

class ScoresWidget extends StatefulWidget {
  final String scoreState;
  final String value;

  const ScoresWidget(
      {super.key, required this.scoreState, required this.value});

  @override
  State<ScoresWidget> createState() => _ScoresWidget();
}

class _ScoresWidget extends State<ScoresWidget> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool? isRecent = true;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    final scoreProvider = Provider.of<ScoresAdminProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _inputDecoration(),
        ),
        if (scoreProvider.isLoading)
          Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.black, size: 70))
        else if(scoreProvider.custScore.isEmpty)
        const Center(
              child:  Center(
                            child: Text('No scores found.')))
         else Expanded(
            child: Column(
              children: [
                _buildFilterButtons(context, height, scoreProvider),
                Expanded(
                  child: ListView.builder(
                    itemCount: scoreProvider.custScore
                        .where((score) => score.event.eventname!
                            .toLowerCase()
                            .contains(searchQuery))
                        .length,
                    itemBuilder: (context, index) {
                      
                      final filteredScores = scoreProvider.custScore
                          .where((score) => score.user.username
                              .toLowerCase()
                              .contains(searchQuery))
                          .toList();

                      if (isRecent != null && isRecent == false) {
                        filteredScores.sort((a, b) => a.score.submissionDate!
                            .compareTo(b.score.submissionDate!));
                      }

                      if (filteredScores.isEmpty) {
                        return const Center(
                            child: Text('No matching scores found.'));
                      }
                      return ScoreCardWidget(score: filteredScores[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _inputDecoration() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          suffixIcon: Align(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (String result) {
                setState(() {
                  switch (result) {
                    case 'recent':
                      isRecent = null;
                      break;
                    case 'old':
                      isRecent = false;
                      break;

                    default:
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'recent',
                  child: Text('Latest'),
                ),
                const PopupMenuItem<String>(
                  value: 'old',
                  child: Text('Oldest'),
                ),
              ],
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(40.0),
          ),
          fillColor: Colors.white,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
            borderRadius: BorderRadius.circular(40.0),
          ),
          labelText: 'Search Posts',
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
    );
  }

  Widget _buildFilterButtons(
      BuildContext context, double height, ScoresAdminProvider scoreProvider) {
    final _ScoreListScreen? parentState =
        context.findAncestorStateOfType<_ScoreListScreen>();

    return SizedBox(
      height: height * 0.09,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterButton(context, parentState, 'All Scores', 'all'),
          _buildFilterButton(
              context, parentState, 'Approved Scores', 'approved'),
          _buildFilterButton(context, parentState, 'Denied Scores', 'denied'),
          _buildFilterButton(context, parentState, 'Pending Scores', 'pending'),
          // const SizedBox(width: 10),
          // _buildDropdownMenu(
          //   context,
          //   'Admin',
          //   scoreProvider.adminusers,
          //   (value) =>
          //       parentState?._updateSelectedWidget('admin', newValue: value),
          // ),
          // const SizedBox(width: 10),
          // _buildDropdownMenu(
          //   context,
          //   'Player',
          //   scoreProvider.users,
          //   (value) =>
          //       parentState?._updateSelectedWidget('player', newValue: value),
          // ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, _ScoreListScreen? parentState,
      String label, String state) {
    bool isSelected = parentState?.scoreType == state;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 7),
      child: ElevatedButton.icon(
        icon: isSelected
            ? const Icon(Icons.check, color: Colors.black)
            : Container(),
        onPressed: () => parentState?._updateSelectedWidget(state),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(255, 147, 122, 39)
              : const Color.fromRGBO(186, 155, 55, 1),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        label: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black)),
      ),
    );
  }
  

  Widget _buildDropdownMenu(BuildContext context, String label,
      List<UserModel> users, Function(String) onSelected) {
    if (users.isEmpty) return const SizedBox.shrink();

    return SizedBox(
        width: 160,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color.fromRGBO(186, 155, 55, 1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                label,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              value: users.first.username,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              style: const TextStyle(color: Colors.black, fontSize: 14),
              items: users.map((user) {
                return DropdownMenuItem(
                  value: user.username,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(user.username),
                  ),
                );
              }).toList(),
              onChanged: (value) => onSelected(value!),
            ),
          ),
        ));
  }
}

class ScoreCardWidget extends StatefulWidget {
  final CustomScoresModel score;

  const ScoreCardWidget({
    super.key,
    required this.score,
  });

  @override
  _ScoreCardWidget createState() => _ScoreCardWidget();
}

class _ScoreCardWidget extends State<ScoreCardWidget> {
  @override
  Widget build(BuildContext context) {
    final _ScoreListScreen? parentState =
        context.findAncestorStateOfType<_ScoreListScreen>();
    String picture;
    if (widget.score.score.scoreimage != null) {
      picture = widget.score.score.scoreimage!;
    } else {
      picture = 'https://picsum.photos/250?image=9';
    }
    //var name = '${widget.score.user.firstname!} ${widget.score.user.lastname}' ;
    var name = widget.score.user.username;
    var score = widget.score.score.score;
    String formattedDate = DateFormat.yMd()
        .format(DateTime.parse(widget.score.score.submissionDate!));

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
                      widget.score.event.eventname!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Status: ${_getStatusText(widget.score.score.approvalstatus!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          _getStatusColor(widget.score.score.approvalstatus!),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
              Text(
                'Player: $name',
                style: const TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.justify,
              ),
              Text(
                'Score: $score',
                style: const TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.justify,
              ),
              Row(
                children: <Widget>[
                  if (widget.score.score.approvalstatus == 'approved')
                    Expanded(
                        flex: 2,
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                              ),
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text(
                              'APPROVED',
                              style: TextStyle(color: Colors.white),
                            )))),
                  if (widget.score.score.approvalstatus == 'not_approved')
                    Expanded(
                        flex: 2,
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                              ),
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                                child: Text(
                              'DENIED',
                              style: TextStyle(color: Colors.white),
                            )))),
                  if (widget.score.score.approvalstatus == 'pending')
                    ElevatedButton(
                        onPressed: () async {
                          log('${widget.score.score.approvalstatus!}');
                          await approveScore(
                              widget.score.score.scoreid.toString());
                          parentState?._updateSelectedWidget('approved');
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                              width: 2, // the thickness
                              color: Colors.black // the color of the border
                              ),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Change this value as needed
                          ),
                        ),
                        child: const Text('Approve',
                            style: TextStyle(color: Colors.white))),
                  const SizedBox(width: 10),
                  if (widget.score.score.approvalstatus == 'pending')
                    ElevatedButton(
                        onPressed: () async {
                          await rejectScore(
                              widget.score.score.scoreid.toString());
                          parentState?._updateSelectedWidget('denied');
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                              width: 2, // the thickness
                              color: Colors.black // the color of the border
                              ),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Change this value as needed
                          ),
                        ),
                        child: const Text(
                          'Deny',
                          style: TextStyle(color: Colors.white),
                        )),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      _showImageDialog(context, picture);
                    },
                    label: const Text(
                      'View',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    icon: const Icon(
                      Icons.image,
                      color: Colors.black,
                      size: 20,
                    ),
                  )
                ],
              ),
              Text(
                'Submission Date: $formattedDate',
                style: const TextStyle(fontSize: 10.5, height: 1.4),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showImageDialog(BuildContext context, String picture) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.transparent, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  picture,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child; // Fully loaded

                    return Center(
                        child: LoadingAnimationWidget.waveDots(
                            color: Colors.white, size: 50));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 50, color: Colors.red);
                  },
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 16,
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return 'Approved';
    case 'pending':
      return 'Pending';
    case 'not_approved':
      return 'Not Approved';
    default:
      return 'Unknown';
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'not_approved':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
