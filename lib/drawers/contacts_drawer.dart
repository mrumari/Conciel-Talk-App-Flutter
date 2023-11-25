import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vrouter/vrouter.dart';

class ContactsDrawer extends StatefulWidget {
  final BuildContext context;
  final String? contactId;
  final bool chat;
  final Function(DragUpdateDetails)? onPanUpdate;

  const ContactsDrawer({
    Key? key,
    required this.context,
    required this.chat,
    this.contactId,
    this.onPanUpdate,
  }) : super(key: key);

  @override
  State<ContactsDrawer> createState() => ContactsDrawerState();
}

class ContactsDrawerState extends State<ContactsDrawer> {
  @override
  Widget build(BuildContext context) {
    return StandardDrawer(
      showSplines: true,
      context: context,
      left: false,
      borderColor: Colors.deepPurple,
      splineColor: Colors.transparent,
      onDrag: widget.onPanUpdate,
      icons: const [
        ConcielIcons.doc_file,
        ConcielIcons.share,
        ConcielIcons.mail,
        ConcielIcons.chat,
        ConcielIcons.phone,
        ConcielIcons.map_marker,
      ],
      onTap: [
        () {
          VRouter.of(context).to('/filemanager');
        },
        () {
          VRouter.of(context).to('/archive');
        },
        () {},
        () async {
          final String? contactId =
              VRouter.of(context).queryParameters['contact'];
          VRouter.of(context).to(
            'contact',
            queryParameters: {'contact': contactId!, 'peep': 'false'},
          );
        },
        () async {
          final String? contactId =
              VRouter.of(context).queryParameters['contact'];
          final contact = await FlutterContacts.getContact(contactId!);
          contact!.phones.isNotEmpty
              ? await launchUrlString(
                  'tel:${contact.phones.first.number}',
                )
              : null;
        },
        () async {
          final String? contactId =
              VRouter.of(context).queryParameters['contact'];
          final contact = await FlutterContacts.getContact(contactId!);
          final address = contact!.addresses.isNotEmpty
              ? contact.addresses.first.address
                  .split(',')
                  .map((part) => part.trim())
                  .join('\n')
              : 'home';
          VRouter.of(context).to(
            'maps',
            queryParameters: {'address': address, 'user': contactId},
          );
        },
      ],
    );
  }
}

/*
types.User? directRoomOtherUser(types.Room room, User user) {
  types.User? otherUser;
  if (room.type == types.RoomType.direct) {
    try {
      otherUser = room.users.firstWhere(
        (u) => u.id != user.uid,
      );
    } catch (e) {
      // Do nothing if other user is not found.
      otherUser = null;
    }
  }
  return otherUser;
}

Future<void> callUser(types.Room room, User user) {
  if (room.type == types.RoomType.direct) {
    try {
      final otherUser = room.users.firstWhere(
        (u) => u.id != user.uid,
      );
      otherUser.phoneNumber != null
          ? callPhoneNumber(otherUser.phoneNumber!)
          : null;
      return HapticFeedback.mediumImpact();
    } catch (e) {
      // Do nothing if other user is not found.
      return HapticFeedback.mediumImpact();
    }
  }
  return HapticFeedback.mediumImpact();

}
*/
