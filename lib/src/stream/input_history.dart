import 'dart:async';
import 'dart:convert';

import 'package:input_history_text_field/src/model/input_history_item.dart';
import 'package:input_history_text_field/src/model/input_history_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputHistory {
  final String _historyKey;
  final int _limit;

  bool _isShow = false;
  InputHistoryItems _histories;
  InputHistoryItems get getHistory => this._histories;

  var listOpen = StreamController<bool>();
  var listShow = StreamController<bool>();
  var listEmpty = StreamController<bool>();
  var list = StreamController<InputHistoryItems>();

  InputHistory(this._historyKey, this._limit) {
    this._init();
  }

  void toggleExpand() {
    if (this._histories.isEmpty) {
      this._forceHide();
      return;
    }

    this._clearFilter();
    this.listOpen.sink.add(!_isShow);
    this.listShow.add(!_isShow);
    _isShow = !_isShow;
  }

  void _forceHide() {
    _isShow = false;
    this._clearFilter();
    this.listOpen.sink.add(_isShow);
    this.listShow.add(_isShow);
  }

  void show() {
    this.listOpen.sink.add(true);
    this.listShow.add(true);
    _isShow = true;
  }

  void hide() {
    this.listOpen.sink.add(false);
    this.listShow.add(false);
    _isShow = false;
  }

  Future<void> _init() async {
    this._histories = InputHistoryItems(this._limit);
    await this._load();
    this.listEmpty.sink.add(this._histories.isEmpty);
    this.list.sink.add(this._histories);
  }

  Future<void> remove(InputHistoryItem item) async {
    _histories.remove(item);
    await _save();
  }

  Future<void> _save() async {
    this.list.sink.add(this._histories);
    await this._savePreference();
  }

  Future<void> add(String text) async {
    if (!this._validate(text)) return;
    _histories.addByText(text);
    await _save();
    this.hide();
  }

  bool _validate(String text) {
    if (text.trim().isEmpty) return false;
    return true;
  }

  Future<void> _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    var json = jsonEncode(_histories.all.map((e) => e.toJson()).toList());
    prefs.setString(this._historyKey, json);
  }

  Future<void> _load() async {
    final items = await this._loadPreference();
    if (items == null || items.isEmpty) return null;
    this._parseToHistories(items);
  }

  Future<String> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getString(this._historyKey);
    return items;
  }

  void _parseToHistories(String jsons) {
    try {
      final parsedJsons = jsonDecode(jsons);
      parsedJsons.forEach((json) {
        if (json is Map<String, dynamic>)
          this._histories.add(InputHistoryItem.fromJson(json));
      });
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }
  }

  void dispose() {
    list.close();
    listOpen.close();
    listShow.close();
    listEmpty.close();
  }

  void _clearFilter() {
    this.list.sink.add(this._histories);
  }

  void filterHistory(String text) {
    if (text.isEmpty) {
      this._clearFilter();
      return;
    }

    var filterdList = this
        ._histories
        .all
        .where((value) => value.text.contains(text))
        .toList();

    InputHistoryItems filterdHistoryItems =
        InputHistoryItems.filterd(this._limit, filterdList);
    this.list.sink.add(filterdHistoryItems);
    this.listEmpty.sink.add(filterdHistoryItems.isEmpty);
  }

  void submit() {
    this.hide();
  }
}
