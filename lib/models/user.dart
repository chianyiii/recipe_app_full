class User {
  int? id;
  String username;
  String passwordHash;
  User({this.id, required this.username, required this.passwordHash});
  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'] as int?,
    username: m['username'] as String,
    passwordHash: m['passwordHash'] as String,
  );
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'username': username,
    'passwordHash': passwordHash,
  };
}
