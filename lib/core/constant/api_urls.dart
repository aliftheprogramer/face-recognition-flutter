class ApiUrls {
  //user
  static const String baseUrl = "https://mas-pos.appmedia.id/api/v1";
  static const String login = "$baseUrl/login";
  static const String profile = "$baseUrl/profile";



  //product
  static const String product = "$baseUrl/product"; //get post delete(id)
  static const String productById = "$baseUrl/product/update";  //(post but edit)


//category
  static const String category = "$baseUrl/category"; //get post delete(id)
  static const String categoryById = "$baseUrl/category/update"; //(post but edit)

}