import 'package:input_history_text_field/src/model/input_history_item.dart';

class InputHistoryItems {
  final int _limit;
  List<InputHistoryItem> _items = List<InputHistoryItem>();
  List<InputHistoryItem> get all => this._items;
  bool get isEmpty => this._items == null || this._items.isEmpty;
  InputHistoryItems(this._limit);
  InputHistoryItems.filterd(this._limit, this._items);

  void addByText(String text) {
    if (!this._validate(text)) return;
    if (_items.length >= this._limit) _items.removeLast();
    _items.insert(0, (InputHistoryItem(text)));
  }

  void add(InputHistoryItem item) {
    this._items.add(item);
  }

  bool _validate(String text) {
    if (this._items.where((value) => value.text == text).length > 0)
      return false;
    return true;
  }

  void remove(InputHistoryItem item) {
    this._items.removeWhere((i) => i.createdTime == item.createdTime);
  }
}
