import 'package:isar_community/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String accountKey; // combintation of url

  late String userId;
  late String userName;
  late String userEmail;
  late String userPhone;
  late String workLocation;
  late String department;
  late String language;
  late String timezone;
  late String emailSignature;
  late String maritalStatus;
  late String profileImageBase64;
  late bool notificationByEmail;
  late bool notificationInOdoo;
  late bool odooBotStatus;
  late String dbName;
  late String serverUrl;
  late String username;
  late String password;
  late String companyId;
  late DateTime lastUpdated;
}

@collection
class SignedAccount {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String accountIdentifier; // url

  late String accountKey;
  late String username;
  late String serverAddress;
  late String database;
  late String password;
  late String userNameDisplay;
  late String profileImage;
}

@collection
class SignedAccountListing {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String accountIdentifier; // url

  late String accountKey;
  late String username;
  late String serverAddress;
  late String database;
  late String password;
  late String userNameDisplay;
  late String profileImage;
  late DateTime lastLoginTime;
}
