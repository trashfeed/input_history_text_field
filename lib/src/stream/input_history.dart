import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:input_history_text_field/src/model/input_history_item.dart';
import 'package:input_history_text_field/src/model/input_history_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputHistoryController {
  late String _historyKey;
  late int _limit;
  late TextEditingController _textEditingController;
  late List<String>? _lockItems;

  bool _isShow = false;
  late InputHistoryItems _histories;
  InputHistoryItems get getHistory => this._histories;

  final listOpen = StreamController<bool>();
  final listShow = StreamController<bool>();
  final listEmpty = StreamController<bool>();
  final list = StreamController<InputHistoryItems>();

  void setup(String historyKey, int limit, _textEditingController, {List<String>? lockItems}) {
    this._historyKey = historyKey;
    this._limit = limit;
    this._lockItems = lockItems;
    this._textEditingController = _textEditingController;
    this._init();
  }

    void toggleExpand() async {
    await this._init();
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
    var json = jsonEncode(_histories.withoutLockItems.map((e) => e.toJson()).toList());
    prefs.setString(this._historyKey, json);
  }

  Future<void> _load() async {
    final items = await this._loadPreference();
    this._parseToHistories(items);
    this._parseLockItems();
  }

  void _parseLockItems() {
    if (this._lockItems == null || this._lockItems!.isEmpty) return;
    this._lockItems!.forEach((item) {
      this._histories.add(InputHistoryItem.lock(item));
    });
  }

  Future<String?> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getString(this._historyKey);
    return items;
  }

  void _parseToHistories(String? jsons) {
    if (jsons == null) {
      return;
    }
    if (jsons.isEmpty) {
      return;
    }
    try {
      final parsedJsons = jsonDecode(jsons);
      parsedJsons.forEach((json) {
        if (json is Map<String, dynamic>) this._histories.add(InputHistoryItem.fromJson(json));
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

    var filterdList = this._histories.all.where((value) => value.text.contains(text) && (value.text != text)).toList();

    InputHistoryItems filterdHistoryItems = InputHistoryItems.filterd(this._limit, filterdList);
    this.list.sink.add(filterdHistoryItems);
    this.listEmpty.sink.add(filterdHistoryItems.isEmpty);
  }

  void select(String text) {
    this._textEditingController.text = text;
    this.hide();
  }
}
