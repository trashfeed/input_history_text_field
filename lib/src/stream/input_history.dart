import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:input_history_text_field/src/model/input_history_item.dart';
import 'package:input_history_text_field/src/model/input_history_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class InputHistoryController {
  static InputHistoryController?
      _activeController; // Global reference to the active controller

  late String _historyKey;
  late int _limit;
  late TextEditingController _textEditingController;
  late List<String>? _lockItems;
  late bool _updateSelectedHistoryItemDateTime;

  bool _isShow = false;
  late InputHistoryItems _histories;
  InputHistoryItems get getHistory => this._histories;

  final listOpen = BehaviorSubject<bool>.seeded(false);
  final listShow = BehaviorSubject<bool>.seeded(false);
  final listEmpty = BehaviorSubject<bool>.seeded(false);
  final list = BehaviorSubject<InputHistoryItems>();
  void setup(
    String historyKey,
    int limit,
    _textEditingController,
    bool updateSelectedHistoryItemDateTime, {
    List<String>? lockItems,
  }) {
    this._historyKey = historyKey;
    this._limit = limit;
    this._lockItems = lockItems;
    this._textEditingController = _textEditingController;
    this._updateSelectedHistoryItemDateTime = updateSelectedHistoryItemDateTime;
    this._init();
  }

  void toggleExpand() async {
    // Hide any other active controller's popup before showing this one
    if (_activeController != null && _activeController != this) {
      _activeController!._forceHide();
    }

    if (!_isShow) await this._init();
    if (this._histories.isEmpty) {
      this._forceHide();
      return;
    }

    _activeController = this; // Set this controller as active
    this._clearFilter();
    this.listOpen.add(!_isShow);
    this.listShow.add(!_isShow);
    _isShow = !_isShow;
  }

  bool isShown() {
    return _isShow;
  }

  void _forceHide() {
    _isShow = false;
    this._clearFilter();
    this.listOpen.add(_isShow);
    this.listShow.add(_isShow);
  }

  void show() {
    if (_activeController != null && _activeController != this) {
      _activeController!._forceHide();
    }

    _activeController = this;
    this.listOpen.add(true);
    this.listShow.add(true);
    _isShow = true;
  }

  void hide() {
    this.listOpen.add(false);
    this.listShow.add(false);
    _isShow = false;
  }

  Future<void> _init() async {
    this._histories = InputHistoryItems(this._limit);
    await this._load();
    this.listEmpty.add(this._histories.isEmpty);
    this.list.add(this._histories);
  }

  Future<void> remove(InputHistoryItem item) async {
    _histories.remove(item);
    await _save();
  }

  Future<void> _save() async {
    this.list.add(this._histories);
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
    var json =
        jsonEncode(_histories.withoutLockItems.map((e) => e.toJson()).toList());
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
        if (json is Map<String, dynamic>)
          this._histories.add(InputHistoryItem.fromJson(json));
      });
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }
  }

  void dispose() {
    _activeController = null;
    list.close();
    listOpen.close();
    listShow.close();
    listEmpty.close();
  }

  void _clearFilter() {
    this.list.add(this._histories);
  }

  void filterHistory(String text) {
    if (text.isEmpty) {
      this._clearFilter();
      return;
    }

    var filteredList = this
        ._histories
        .all
        .where((value) => value.text.contains(text) && (value.text != text))
        .toList();

    InputHistoryItems filteredHistoryItems =
        InputHistoryItems.filterd(this._limit, filteredList);
    this.list.add(filteredHistoryItems);
    this.listEmpty.add(filteredHistoryItems.isEmpty);
  }

  Future<void> select(String text) async {
    this._textEditingController.text = text;
    if (_updateSelectedHistoryItemDateTime) {
      _histories.updateByText(text);
      await _save();
    }
    this.hide();
  }
}
