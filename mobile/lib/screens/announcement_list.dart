import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/arguments/announcementargument.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcement_info.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:coffee_card/widgets/events_widgets.dart';
import 'package:coffee_card/widgets/slideRightTransition.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/announcement_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreen();
}

class _AnnouncementListScreen extends State<AnnouncementListScreen> {
  AnnouncementProvider? announcementProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool _isInit = true;
  bool _isLoading = false;
  bool? isRecent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        announcementProvider =
            Provider.of<AnnouncementProvider>(context, listen: false);
        announcementProvider!.fetchAnnouncements();
      });
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Announcements', showBackButton: true, actions: [
          Visibility(
              //visible: announcementProvider!.roleid == '5',
              child: TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AnnouncementCreationScreen.routeName,
                arguments: AnnouncementCreateArg(false, AnnouncementModel()),
              );
              // Force refresh after returning from create post screen
              announcementProvider!.fetchAnnouncements();
            },
            child: const Text('+ Create'),
          )),
        ],),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
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
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'recent',
                          child: Text('Newest Posts'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'old',
                          child: Text('Oldest Posts'),
                        ),
                      ],
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
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
            ),
          ),
          Expanded(
            child: Consumer<AnnouncementProvider>(
              builder: (context, announcementProvider, child) {
                if (announcementProvider.isLoading) {
                  return  Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                          color: Colors.black, size: 70));
                }

                final filteredAnnouncements =
                    announcementProvider.getFilteredAnnc(searchQuery);
                if (isRecent != null && isRecent == false) {
                  filteredAnnouncements
                      .sort((a, b) => a.createddate!.compareTo(b.createddate!));
                }

                return announcementProvider.isLoading
                    ? Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                            color: Colors.black, size: 70))
                    : filteredAnnouncements.isEmpty
                        ? const Center(child: Text('No matching posts found.'))
                        : AnncListView(
                            filteredAnnouncements: filteredAnnouncements,
                            annc: announcementProvider,
                          );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnncListView extends StatelessWidget {
  final List<AnnouncementModel> filteredAnnouncements;
  final AnnouncementProvider annc;

  const AnncListView({
    required this.filteredAnnouncements,
    required this.annc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredAnnouncements.length,
      itemBuilder: (context, index) {
        final announcement = filteredAnnouncements[index];
        if (index == filteredAnnouncements.length - 1) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  slideRightRoute(AnnouncementInfo(
                      id: announcement.announcementid!.toString())));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: AnnouncementWidget(
                announcement: announcement,
                username: annc.postUsers[announcement.announcementid],
              ),
            ),
          );
        } else {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  slideRightRoute(AnnouncementInfo(
                      id: announcement.announcementid!.toString())));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: AnnouncementWidget(
                announcement: announcement,
                username: annc.postUsers[announcement.announcementid],
              ),
            ),
          );
        }
      },
    );
  }
}
