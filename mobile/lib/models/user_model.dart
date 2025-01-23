class UserModel {
  final int id;
  final String username;
  final String email;
  final String password;
  final String? firstname; // Nullable
  final String? lastname; // Nullable
  final int roleid;
  final bool paymentstatus;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.firstname,
    this.lastname,
    required this.roleid,
    required this.paymentstatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      firstname: json['firstname'], 
      lastname: json['lastname'],
      roleid: json['roleid'],
      paymentstatus: json['paymentstatus'],
    );
  }
}
