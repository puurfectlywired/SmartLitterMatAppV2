
//holds user data temporarily through the registration process

///////////////////////////////////////USER REGISTRATION MODEL///////////////////////////

class UserRegistration {
  String firstName;
  String lastName;
  String email;
  String username;
  String password;

  UserRegistration({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.username = '',
    this.password = '',
  });
}