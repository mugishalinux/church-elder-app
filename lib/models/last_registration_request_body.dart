import 'dart:convert';

class LastRegistrationBody {
  int? messageNumber;
  String? messageTime;
  bool bothReceiveMessage;
  String? secondPhone;
  String? childrenNumber;
  DateTime? periodDate;

  LastRegistrationBody({
    required this.messageNumber,
    required this.messageTime,
    required this.bothReceiveMessage,
    required this.secondPhone,
    required this.childrenNumber,
    required this.periodDate,
  });

  factory LastRegistrationBody.fromJson(Map<String, dynamic> json) {
    return LastRegistrationBody(
      messageNumber: json['messageNumber'],
      messageTime: json['messageTime'],
      bothReceiveMessage: json['bothReceiveMessage'],
      secondPhone: json['secondPhone'],
      childrenNumber: json['childrenNumber'],
      periodDate: json['periodDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageNumber': messageNumber,
      'messageTime': messageTime,
      'bothReceiveMessage': bothReceiveMessage,
      'secondPhone': secondPhone,
      'childrenNumber': childrenNumber,
      'periodDate': periodDate
    };
  }

  // Convert JSON string to User object
  static LastRegistrationBody fromJsonString(String jsonString) {
    return LastRegistrationBody.fromJson(json.decode(jsonString));
  }

  // Convert User object to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }
}
