// class TradesModel {
//   String what;
//   String to;

//   TradesModel({this.what, this.to});

//   TradesModel.fromJson(Map<String, dynamic> json) {
//     what = json['what'];
//     to = json['for'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['what'] = this.what;
//     data['for'] = this.to;
//     return data;
//   }
// }
class TradesModel {
  List<Trade> trades;

  TradesModel._(this.trades);

  static TradesModel fromJson(List json) {
    return TradesModel._(json.map<Trade>((e) => Trade.fromJson(e)).toList());
  }
}

class Trade {
  String what;
  String to;

  Trade._(this.what, this.to);

  static Trade fromJson(Map json) {
    return Trade._(json["what"], json["for"]);
  }
}
