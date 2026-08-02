class UserModel {
  final String uid;
  final String name;
  final String email;
  final String mobile;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'createdAt': DateTime.now(),
    };
  }
}