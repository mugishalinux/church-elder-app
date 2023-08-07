class Church {
  final int id;
  final String churchName;

  Church({
    required this.id,
    required this.churchName,
  });

  factory Church.fromJson(Map<String, dynamic> json) {
    return Church(
      id: json['id'],
      churchName: json['churchName'],
    );
  }
}
