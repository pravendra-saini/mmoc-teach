class UserModel {
  final String uid;
  final String name;
  final String email;
  final String mobile;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.mobile,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mobile': mobile,
      'createdAt': DateTime.now(),
    };
  }
}