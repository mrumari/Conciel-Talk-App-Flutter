# Privacy

 Conciel is available on Android and iOS. Web and Desktop versions for Windows, Linux and macOS may follow.

*   [Matrix](#matrix)
*   Sentry
*   [Database](#database)
*   [Encryption](#encryption)
*   [App Permissions](#app-permissions)
*   [Push Notifications](#push-notifications)
*   [Stories](#stories)

## Matrix<a id="matrix"/>
 Conciel uses the Matrix protocol, but Conciel can only be connected to Conciel Matrix servers, as such our data protection agreement always applies.

For convenience, one or more servers are set as default by Conciel developers.

 Conciel only communicates with Conciel servers, with sentry.io if enabled and with [Google Maps](https://maps.google.com) to display maps.

## Database<a id="database"/>
 Conciel caches some data received from the server in a local database on the device of the user.

More information is available at: [https://pub.dev/packages/hive](https://pub.dev/packages/hive)

## Encryption<a id="encryption"/>
All communication of substantive content between the Conciel App and the Conciel Matrix server is done in a secure way, using transport encryption to protect it.

 Conciel is also able to use End-To-End-Encryption.

## App Permissions<a id="app-permissions"/>

The permissions are the same on Android and iOS but may differ in the name. These are the Android Permissions:

#### Internet Access
 Conciel needs to have internet access to communicate with the Matrix Server.

#### Vibrate
 Conciel uses vibration for local notifications. More informations about this are at the used package:
[https://pub.dev/packages/flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

#### Record Audio
 Conciel can send voice messages in a chat and therefore needs to have the permission to record audio.

#### Write External Storage
The user is able to save received files and therefore app needs this permission.

#### Read External Storage
The user is able to send files from the device's file system.

#### Location
 Conciel makes it possible to share the current location via the chat. When the user shares their location, Conciel uses the device location service and sends the geo-data via Matrix.

## Push Notifications<a id="push-notifications"/>
 Conciel uses the Firebase Cloud Messaging service for push notifications on Android and iOS. This takes place in the following steps:
1. The matrix server sends the push notification to the Conciel Push Gateway
2. The Conciel Push Gateway forwards the notification in a different format to Firebase Cloud Messaging
3. Firebase Cloud Messaging waits until the user's device is online again
4. The device receives the push notification from Firebase Cloud Messaging and displays it as a notification

`event_id_only` is used as the format for the push notification. A typical push notification therefore only contains:
- Event ID
- Room ID
- Unread Count
- Information about the device that is to receive the message

A typical push notification could look like this:
```json
{
  "notification": {
    "event_id": "$3957tyerfgewrf384",
    "room_id": "!slw48wfj34rtnrf:example.com",
    "counts": {
      "unread": 2,
      "missed_calls": 1
    },
    "devices": [
      {
        "app_id": "chat.conciel.concieltalk",
        "pushkey": "V2h5IG9uIGVhcnRoIGRpZCB5b3UgZGVjb2RlIHRoaXM/",
        "pushkey_ts": 12345678,
        "data": {},
        "tweaks": {
          "sound": "bing"
        }
      }
    ]
  }
}
```

 Conciel sets the `event_id_only` flag at the Conciel Server. This server is then responsible to send the correct data.

## Stories<a id="stories"/>

 Conciel supports stories which is a feature similar to WhatsApp status or Instagram stories.

Stories are basically:

- End to end encrypted rooms
- Read-only rooms with only one admin who can post (while there is no technical limitation to have multiple admins)

By default:

- The user has to invite all contacts manually to a story room
- The user can only invite contacts (matrix users the user shares a DM room with) to the story room
- The story room is created when the first story is posted
- User can mute and leave story rooms

The user is informed in the app that in theory all contacts can see each other in the story room. The user must give consent here. However the user is at any time able to create a group chat and invite all of their contacts to this chat in any matrix client which has the same result.
