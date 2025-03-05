import 'package:coffee_card/models/announcement_model.dart';

class AnnouncementCreateArg {
  final bool isUpdate;
  final AnnouncementModel anc;
  AnnouncementCreateArg(this.isUpdate, this.anc);
}
