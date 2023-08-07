class RegistrationDto {
  String names;
  int province;
  int district;
  int sector;
  int cell;
  int village;
  String martialStatus;
  int childreenNumber;
  String primaryPhone;
  String secondaryPhone;
  int messageNumber;
  String access_level;
  String password;
  String messageTime;
  bool bothReceiveMessage;

  RegistrationDto({
    required this.names,
    required this.province,
    required this.district,
    required this.sector,
    required this.cell,
    required this.village,
    required this.martialStatus,
    required this.childreenNumber,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.messageNumber,
    required this.access_level,
    required this.password,
    required this.messageTime,
    required this.bothReceiveMessage,
  });

  factory RegistrationDto.fromJson(Map<String, dynamic> json) {
    return RegistrationDto(
      names: json['names'],
      province: json['province'],
      district: json['district'],
      sector: json['sector'],
      cell: json['cell'],
      village: json['village'],
      martialStatus: json['martialStatus'],
      childreenNumber: json['childreenNumber'],
      primaryPhone: json['primaryPhone'],
      secondaryPhone: json['secondaryPhone'],
      messageNumber: json['messageNumber'],
      access_level: json['access_level'],
      password: json['password'],
      messageTime: json['messageTime'],
      bothReceiveMessage: json['bothReceiveMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['names'] = names;
    data['province'] = province;
    data['district'] = district;
    data['sector'] = sector;
    data['cell'] = cell;
    data['village'] = village;
    data['martialStatus'] = martialStatus;
    data['childreenNumber'] = childreenNumber;
    data['primaryPhone'] = primaryPhone;
    data['secondaryPhone'] = secondaryPhone;
    data['messageNumber'] = messageNumber;
    data['access_level'] = access_level;
    data['password'] = password;
    data['messageTime'] = messageTime;
    data['bothReceiveMessage'] = bothReceiveMessage;
    return data;
  }
}
