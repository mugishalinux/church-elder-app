class Categories {
  int id;
  String categoryName;
  int status;
  int createdBy;
  int updatedBy;
  DateTime createdAt;
  DateTime updatedAt;

  Categories({
    required this.id,
    required this.categoryName,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['id'],
      categoryName: json['cateogryName'], // Note the typo in the key name
      status: json['status'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
