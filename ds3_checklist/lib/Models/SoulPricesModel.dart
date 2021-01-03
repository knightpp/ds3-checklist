class SoulPricesModel {
  List<Soul> souls;

  SoulPricesModel._(this.souls);
  static SoulPricesModel fromJson(List json) {
    return SoulPricesModel._(json.map<Soul>((e) => Soul.fromJson(e)).toList());
  }
}

class Soul {
  String name;
  int price;

  Soul._(this.name, this.price);
  static Soul fromJson(Map json) {
    return Soul._(json["name"], json["souls"]);
  }
}
