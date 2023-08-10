class Config {
  static const String appUrl = "http://192.168.1.64:7000";
  static const String loginApiUser = "$appUrl/user/auth/login/user";
  static const String registerApiUser = "$appUrl/user/createMentor";
  static const String getProvinceApi = "$appUrl/location/province";
  static const String getDistrictApi = "$appUrl/location/district";
  static const String getSectorApi = "$appUrl/location/sector";
  static const String loginApi = "$appUrl/user/auth/login/user";
  static const String victimApi = "$appUrl/victim";
  static const String categoryApi = "$appUrl/category";
  static const String registerVictimApi = "$appUrl/victim/creation";
  static const String getChurches = "$appUrl/church";
  static const String resetPasswordApi = "$appUrl/user/forget/password";
  static const String registerChristianApi = "$appUrl/christian/creation";
  static const String updateChristianApi = "$appUrl/christian";
  static const String fetchChristianApi = "$appUrl/christian";
  static const String postApi = "$appUrl/post/creation";
}
