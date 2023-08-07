class User {
  int id;
  String name;
  String phone;
  String text;
  String jwtToken;

  User(
      {required this.id,
      required this.name,
      required this.phone,
      required this.text,
      required this.jwtToken});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['names'],
      phone: json['phone'],
      text: json['text'],
      jwtToken: json['jwtToken'],
    );
  }
}
