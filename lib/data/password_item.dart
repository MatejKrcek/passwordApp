class Password {
  final String id;
  final String name;
  final String username;
  final String password;
  final String date;

  Password({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.date,
  });

  Map<String, dynamic> get attributes {
    var data = {
      "id": id,
      "name": name,
      "username": username,
      "password": password,
      "date": date
    };
    data["id"] = id;
    return data;
  }

  factory Password.fromMap({required Map<String, dynamic> data}) {
    return Password(
      id: data["id"],
      name: data["name"],
      username: data["username"],
      password: data["password"],
      date: data["date"],
    );
  }
}
