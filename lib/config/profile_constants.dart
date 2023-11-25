import 'package:hive/hive.dart';

part 'profile_constants.g.dart';

// Profile database value keys
// Database collections
const mandatory = 'mandatory';
const residentialAddress = 'residentialAddress';
const security = 'security';
const level1 = 'level1';
const level2 = 'level2';
// boolean identifiers
const register = 'register';
const swipeBack = 'swipeBack';
const useFingerprint = 'useFingerPrint';
const dateTime = 'dateTime'; // use system time
const useLocation = 'useLocation';
const darkMode = 'darkMode';
const notifications = 'notifications';
const haptix = 'haptix';
const stayLoggedIn = 'stayLoggedIn';
// primary user settings
const messagingToken = 'messageToken';
const phoneNumber = 'phoneNumber';
const email = 'email';
const language = 'language';
const nickname = 'nickname';
const displayName = 'nickname'; // alternative primary name identifier
const firstName = 'firstName';
const surname = 'surname';
const birthdate = 'birthdate';
const signature = 'signature';
const password = 'password';
const identification = 'identification';
const idType = 'idType';
const citizenCountry = 'citizenCountry';
const domicileAddress = 'domicileAddress';
const address = 'address';

@HiveType(typeId: 0)
class HiveFile {
  @HiveField(0)
  final String location;

  @HiveField(1)
  final String name;

  HiveFile({required this.location, required this.name});
}

@HiveType(typeId: 1)
class Mandatory {
  @HiveField(0)
  String nickname;
  @HiveField(1)
  String phoneNumber;
  @HiveField(2)
  String email;
  @HiveField(3)
  Address? residentialAddress;

  Mandatory({
    required this.nickname,
    required this.phoneNumber,
    required this.email,
    this.residentialAddress,
  });
}

@HiveType(typeId: 2)
class Address {
  @HiveField(0)
  String street;
  @HiveField(1)
  String streetNumber;
  @HiveField(2)
  String city;
  @HiveField(3)
  String region;
  @HiveField(4)
  String postcode;

  Address({
    required this.street,
    required this.streetNumber,
    required this.city,
    required this.region,
    required this.postcode,
  });
}
