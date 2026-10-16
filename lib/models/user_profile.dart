

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String? password;


  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
  });
}