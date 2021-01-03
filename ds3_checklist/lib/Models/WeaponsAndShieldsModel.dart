class WaSModel {
  List<Category> categories;

  WaSModel._(this.categories);
  static WaSModel fromJson(List json) {
    return WaSModel._(json.map<Category>((e) => Category.fromJson(e)).toList());
  }
}

class Category {
  String name;
  List<Item> items;

  Category._(this.name, this.items);
  static Category fromJson(Map json) {
    List<Item> items =
        json["item_names"].map<Item>((e) => Item.fromJson(e)).toList();
    return Category._(json["category"], items);
  }
}

class Item {
  String name;

  Item._(this.name);

  static Item fromJson(String json) {
    return Item._(json);
  }
}
