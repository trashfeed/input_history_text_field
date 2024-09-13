class InputHistoryItem {
  late String text;
  late int createdTime;
  late int pinnedTime;
  bool isLock = false;

  String get createdTimeLabel {
    var dt = DateTime.fromMillisecondsSinceEpoch(this.createdTime)
        .toLocal()
        .toString();
    return dt.substring(0, dt.lastIndexOf("."));
  }

  InputHistoryItem(String text) {
    this.text = text;
    this.createdTime = DateTime.now().millisecondsSinceEpoch;
    this.pinnedTime = 0;
  }

  InputHistoryItem.fromJson(Map<String, dynamic> json) {
    this.text = json['text'].toString();
    this.createdTime = int.tryParse(json['createdTime'].toString()) ?? 0;
    this.pinnedTime = int.tryParse(json['pinnedTime'].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'createdTime': createdTime, 'pinnedTime': pinnedTime};
  }

  InputHistoryItem.lock(String text) {
    this.text = text;
    this.createdTime = DateTime.now().millisecondsSinceEpoch;
    this.pinnedTime = 0;
    this.isLock = true;
  }
}
