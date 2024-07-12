class Christian {
  final int id;
  final String lastName;
  final String firstName;
  final DateTime dob;
  final String email;
  final bool isBaptised;

  Christian({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.dob,
    required this.email,
    required this.isBaptised,
  });

  factory Christian.fromJson(Map<String, dynamic> json) {
    return Christian(
      id: json['id'],
      lastName: json['lastName'],
      firstName: json['firstName'],
      dob: DateTime.parse(json['dob']),
      email: json['email'],
      isBaptised: json['isBaptised'],
    );
  }
}
