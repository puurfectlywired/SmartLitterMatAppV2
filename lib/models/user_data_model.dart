
//holds user data from firestore
//does NOT include password

//////////////////////////////////////USER DATA MODEL////////////////////////////
class UserData {
  String uid;
  String firstName;
  String lastName;
  String email;
  String username;

  UserData({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
  });

  //create user data from firebase
  factory UserData.fromFirestore(
      String uid,
      Map<String, dynamic> data,
    ) {
      return UserData(
        uid: uid,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        email: data['email'] ?? '',
        username: data['username'] ?? '',
      );
    }

}