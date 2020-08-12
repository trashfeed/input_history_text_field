import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:input_history_text_field/src/model/input_history_item.dart';
import 'package:input_history_text_field/src/model/input_history_items.dart';
import 'package:input_history_text_field/src/stream/input_history.dart';

class InputHistoryTextFieldState extends State<InputHistoryTextField> {
  InputHistory _inputHistory;
  OverlayEntry _overlayHistoryList;

  @override
  void initState() {
    super.initState();
    this._initWidgetState();
  }

  void _initWidgetState() {
    if (!widget.enableHistory) return;
    widget.focusNode ??= FocusNode();
    widget.textEditingController ??= TextEditingController();
    widget.textEditingController.addListener(_onTextChange);
    widget.focusNode.addListener(_onFocusChange);
    _inputHistory = InputHistory(widget.historyKey, widget.limit);
  }

  void _onTextChange() {
    this._inputHistory.filterHistory(widget.textEditingController.text);
  }

  void _onFocusChange() {
    if (this.widget.hasFocusExpand) this._toggleOverlayHistoryList();
    if (!widget.focusNode.hasFocus) _saveHistory();
  }

  void _saveHistory() {
    final text = widget.textEditingController.text;
    _inputHistory.add(text);
  }

  @override
  void dispose() {
    super.dispose();
    this._inputHistory.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _textField();
  }

  Future<void> _toggleOverlayHistoryList() async {
    this._initOverlay();
    if (!widget.focusNode.hasFocus) {
      this._inputHistory.hide();
      return;
    }
    this._inputHistory.toggleExpand();
  }

  void _initOverlay() {
    if (this._overlayHistoryList != null) return;
    this._overlayHistoryList = this._historyListContainer();
    Overlay.of(context).insert(this._overlayHistoryList);
  }

  OverlayEntry _historyListContainer() {
    final render = context.findRenderObject() as RenderBox;
    return OverlayEntry(
      builder: (context) {
        return StreamBuilder<bool>(
          stream: this._inputHistory.listShow.stream,
          builder: (context, shown) {
            if (!shown.hasData) return SizedBox.shrink();
            return Stack(
              children: <Widget>[_historyList(context, render, shown.data)],
            );
          },
        );
      },
    );
  }

  Decoration _listDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 3,
        ),
      ],
    );
  }

  Widget _historyList(BuildContext context, RenderBox render, bool isShow) {
    final offset = render.localToGlobal(Offset.zero);
    final listOffset = widget.listOffset ?? Offset(0, 0);
    return Positioned(
        top: offset.dy + render.size.height + listOffset.dy,
        left: offset.dx + listOffset.dx,
        width: isShow ? render.size.width : 0,
        height: isShow ? null : 0,
        child: Material(
          child: Container(
            decoration: widget.listDecoration ?? _listDecoration(),
            child: StreamBuilder<InputHistoryItems>(
              stream: this._inputHistory.list.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError || !isShow)
                  return SizedBox.shrink();
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  itemCount: snapshot.data.all.length,
                  itemBuilder: (context, index) {
                    return Opacity(
                      opacity: widget.enableOpacityGradient
                          ? 1 - index / snapshot.data.all.length
                          : 1,
                      child: _historyItem(snapshot.data.all[index]),
                    );
                  },
                );
              },
            ),
          ),
        ));
  }

  Widget _historyItem(InputHistoryItem item) {
    return Container(
      decoration: widget.listRowDecoration ?? null,
      child: ListTile(
        onTap: () {
          widget.textEditingController.text = item.text;
          this._inputHistory.submit();
        },
        leading: widget.showHistoryIcon
            ? Icon(
                widget.historyIcon,
                color: Theme.of(context).disabledColor,
              )
            : null,
        dense: true,
        title: Text(
          item.textToSingleLine,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: widget.showDeleteIcon
            ? IconButton(
                color: Theme.of(context).disabledColor,
                icon: Icon(widget.deleteIcon),
                onPressed: () {
                  _inputHistory.remove(item);
                },
              )
            : null,
      ),
    );
  }

  void _onTap() {
    widget.onTap?.call();
    if (widget.textEditingController == null) return;
    final endPosition = widget.textEditingController.selection.end;
    final textLength = widget.textEditingController.text.length;
    if (endPosition == textLength) this._toggleOverlayHistoryList();
  }

  Widget _textField() {
    return TextField(
        key: widget.key,
        controller: widget.textEditingController,
        focusNode: widget.focusNode,
        decoration: widget.decoration,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        textDirection: widget.textDirection,
        readOnly: widget.readOnly,
        toolbarOptions: widget.toolbarOptions,
        showCursor: widget.showCursor,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        enableSuggestions: widget.enableSuggestions,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        expands: widget.expands,
        maxLength: widget.maxLength,
        maxLengthEnforced: widget.maxLengthEnforced,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        selectionHeightStyle: widget.selectionHeightStyle,
        selectionWidthStyle: widget.selectionWidthStyle,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        dragStartBehavior: widget.dragStartBehavior,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        onTap: _onTap,
        buildCounter: widget.buildCounter,
        scrollController: widget.scrollController,
        scrollPhysics: widget.scrollPhysics);
  }
}
