class ArmorModel {
  List<Category> categories;

  ArmorModel._(this.categories);
  static ArmorModel fromJson(List json) {
    return ArmorModel._(
        json.map<Category>((e) => Category.fromJson(e)).toList());
  }
}

class Category {
  String name;
  List<Item> items;

  Category._(this.name, this.items);
  static Category fromJson(Map json) {
    return Category._(json["category"],
        json["gear_names"].map<Item>((e) => Item.fromJson(e)).toList());
  }
}

class Item {
  String name;

  Item._(this.name);

  static Item fromJson(String json) {
    return Item._(json);
  }
}
