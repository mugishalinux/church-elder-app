class Christian {
  final int id;
  final String lastName;
  final String firstName;
  final DateTime dob;
  final String primaryPhone;
  final bool isBaptised;

  Christian({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.dob,
    required this.primaryPhone,
    required this.isBaptised,
  });

  factory Christian.fromJson(Map<String, dynamic> json) {
    return Christian(
      id: json['id'],
      lastName: json['lastName'],
      firstName: json['firstName'],
      dob: DateTime.parse(json['dob']),
      primaryPhone: json['primaryPhone'],
      isBaptised: json['isBaptised'],
    );
  }
}
