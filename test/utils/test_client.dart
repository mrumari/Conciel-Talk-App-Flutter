// ignore_for_file: depend_on_referenced_packages

import 'package:matrix/encryption/utils/key_verification.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix_api_lite/fake_matrix_api.dart';

import 'package:concieltalk/utils/matrix_sdk_extensions/flutter_hive_collections_database.dart';

Future<Client> prepareTestClient({
  bool loggedIn = false,
  Uri? conciel,
  String id = 'ConcielTalk Widget Test',
}) async {
  conciel ??= Uri.parse('https://fakeserver.notexisting');
  final client = Client(
    'ConcielTalk Widget Tests',
    httpClient: FakeMatrixApi(),
    verificationMethods: {
      KeyVerificationMethod.numbers,
      KeyVerificationMethod.emoji,
    },
    importantStateEvents: <String>{
      'im.ponies.room_emotes', // we want emotes to work properly
    },
    databaseBuilder: FlutterHiveCollectionsDatabase.databaseBuilder,
    supportedLoginTypes: {
      AuthenticationTypes.password,
      AuthenticationTypes.sso,
    },
  );
  await client.checkHomeserver(conciel);
  if (loggedIn) {
    await client.login(
      LoginType.mLoginToken,
      identifier: AuthenticationUserIdentifier(user: '@alice:example.invalid'),
      password: '1234',
    );
  }
  return client;
}
