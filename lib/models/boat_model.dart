class BoatData {
  final int id;
  final int price;
  final int maxNumber;
  final List<String> boatImages;

  BoatData(
      {required this.id,
      required this.price,
      required this.maxNumber,
      required this.boatImages});

  factory BoatData.fromJson(Map<String, dynamic> json) {
    return BoatData(
      id: json['id'],
      price: json['price'],
      maxNumber: json['maxNumber'],
      boatImages: json['boatImages'].toString().split(','),
    );
  }
}
