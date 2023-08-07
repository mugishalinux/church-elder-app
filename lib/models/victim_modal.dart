class Victim {
  int id;
  String lastName;
  String firstName;
  DateTime dob;
  String primaryPhone;
  int status;
  int createdBy;
  int updatedBy;
  DateTime createdAt;
  DateTime updatedAt;
  Category category;

  Victim({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.dob,
    required this.primaryPhone,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  // Define a constructor to parse JSON
  factory Victim.fromJson(Map<String, dynamic> json) {
    return Victim(
      id: json['id'],
      lastName: json['lastName'],
      firstName: json['firstName'],
      dob: DateTime.parse(json['dob']),
      primaryPhone: json['primaryPhone'],
      status: json['status'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: Category.fromJson(json['category']),
    );
  }
}

class Category {
  int id;
  String categoryName;
  int status;
  int createdBy;
  int updatedBy;
  DateTime createdAt;
  DateTime updatedAt;

  Category({
    required this.id,
    required this.categoryName,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Define a constructor to parse JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryName: json[
          'cateogryName'], // Note the typo in the field name 'cateogryName'
      status: json['status'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
