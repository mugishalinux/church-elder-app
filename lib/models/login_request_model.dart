class LoginRequestModel {
  String email = "";
  String password = "";
  String logger = "";

  LoginRequestModel({required this.email, required this.password, required this.logger});

  LoginRequestModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    logger = json['logger'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = email;
    data['password'] = password;
    data['logger'] = logger;
    return data;
  }
}
