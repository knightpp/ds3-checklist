abstract class AchsModel {
  static List<Achievement> fromJson(List json) {
    return json.map((el) => Achievement.fromJson(el)).toList();
  }
}

abstract class TasksModel {
  static List<Task> fromJson(List json) {
    return json.map((el) => Task.fromJson(el)).toList();
  }
}

class Achievement {
  String name;
  List<Task> tasks;

  Achievement._({required this.name, required this.tasks});

  static Achievement fromJson(dynamic json) {
    return Achievement._(
        name: json["name"], tasks: TasksModel.fromJson(json["tasks"]));
  }
}

class Task {
  String itemName;
  String description;
  String availableFrom;
  Task._(
      {required this.itemName,
      required this.description,
      required this.availableFrom});

  static Task fromJson(dynamic json) {
    return Task._(
        itemName: json["item_name"],
        description: json["description"],
        availableFrom: json["available_from"]);
  }
}
