enum UserType {
  Admin,
  Organizer,
  Participant,
}

class User {
  final String name;
  final String email;
  final String password;
  final UserType userType;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });
}
