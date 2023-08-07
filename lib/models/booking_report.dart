class BookingData {
  final int id;
  final int bookingRef;
  final DateTime bookingDate;
  final String bookingFrom;
  final String bookingTo;
  final String names;
  final String phoneNumber;
  final String? paymentStatus;

  BookingData({
    required this.id,
    required this.bookingRef,
    required this.bookingDate,
    required this.bookingFrom,
    required this.bookingTo,
    required this.names,
    required this.phoneNumber,
    required this.paymentStatus,
  });
  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      id: json['id'],
      bookingRef: json['bookingRef'],
      bookingDate: json['bookingDate'],
      bookingFrom: json['bookingFrom'],
      bookingTo: json['bookingbookingToDate'],
      names: json['names'],
      phoneNumber: json['phoneNumber'],
      paymentStatus: json['paymentStatus'],
    );
  }
}
