import 'package:flutter/material.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:input_history_text_field/src/model/input_history_item.dart';
import 'package:input_history_text_field/src/model/input_history_items.dart';

class InputHistoryTextFieldState extends State<InputHistoryTextField> {
  late InputHistoryController _inputHistoryController;
  late String Function(String) _textToSingleLine;
  late FocusNode _focusNode;
  OverlayEntry? _overlayHistoryList;
  String? _lastSubmitValue;

  @override
  void initState() {
    super.initState();
    _initWidgetState();
    _initController();
  }

  void _initWidgetState() {
    if (!widget.enableHistory) return;
    _focusNode = widget.focusNode ??= FocusNode();
    _textToSingleLine = widget.textToSingleLine ?? _defaultTextToSingleLine;
    widget.textEditingController ??=
        TextEditingController(text: _lastSubmitValue);
    if (widget.enableFilterHistory)
      widget.textEditingController?.addListener(_onTextChange);
    _focusNode.addListener(_onFocusChange);
  }

  void _initController() {
    _inputHistoryController =
        widget.inputHistoryController ?? InputHistoryController();
    _inputHistoryController.setup(
      widget.historyKey,
      widget.limit,
      widget.textEditingController,
      widget.updateSelectedHistoryItemDateTime,
      lockItems: widget.lockItems,
    );
  }

  void _onTextChange() {
    _inputHistoryController.filterHistory(widget.textEditingController!.text);
    if (_focusNode.hasFocus && !_inputHistoryController.isShown()) {
      _inputHistoryController.toggleExpand();
    }
  }

  void _onFocusChange() {
    if (_overlayHistoryList == null) {
      _initOverlay(); // Initialize the overlay right away
    }
    if (_focusNode.hasFocus && _overlayHistoryList == null) {
      _toggleOverlayHistoryList();
    }
    if (widget.textEditingController!.text != _lastSubmitValue &&
        !_focusNode.hasFocus) {
      _saveHistory();
      _lastSubmitValue = widget.textEditingController!.text;
    }
  }

  void _saveHistory() {
    if (!widget.enableSave) return;
    final text = widget.textEditingController?.text;
    _inputHistoryController.add(text ?? '');
  }

  @override
  void dispose() {
    super.dispose();
    _inputHistoryController.dispose();
    _focusNode.dispose();
    _overlayHistoryList?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return _textField();
  }

  Future<void> _toggleOverlayHistoryList() async {
    if (!widget.showHistoryList) return;

    if (_focusNode.hasFocus) {
      _inputHistoryController.toggleExpand();
    } else {
      _inputHistoryController.hide();
    }
  }

  void _initOverlay() {
    _overlayHistoryList = _historyListContainer();
    Overlay.of(context).insert(_overlayHistoryList!);
  }

  OverlayEntry _historyListContainer() {
    final render = context.findRenderObject() as RenderBox;
    return OverlayEntry(
      builder: (context) {
        return StreamBuilder<bool>(
          stream: _inputHistoryController.listShow.stream,
          builder: (context, shown) {
            if (!shown.hasData ||
                shown.connectionState == ConnectionState.waiting)
              return SizedBox.shrink();
            return Stack(
              children: <Widget>[
                shown.data! ? _backdrop(context) : SizedBox.shrink(),
                _historyList(context, render, shown.data!),
              ],
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
      top: offset.dy +
          render.size.height +
          (widget.listStyle == ListStyle.Badge
              ? listOffset.dy + 10
              : listOffset.dy),
      left: offset.dx + listOffset.dx,
      width: isShow ? render.size.width : 0,
      height: isShow ? null : 0,
      child: Material(
        child: widget.overlayHeight != null
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.overlayHeight!,
                ),
                child: _listContainer(render, isShow),
              )
            : _listContainer(render, isShow),
      ),
    );
  }

  Widget _listContainer(RenderBox render, bool isShow) {
    return Container(
      decoration: widget.listStyle == ListStyle.Badge
          ? null
          : widget.listDecoration ?? _listDecoration(),
      child: StreamBuilder<InputHistoryItems>(
        stream: _inputHistoryController.list.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError || !isShow)
            return SizedBox.shrink();
          if (widget.listStyle == ListStyle.Badge) {
            return Wrap(
              children: [
                for (var item in snapshot.data!.all) _badgeHistoryItem(item)
              ],
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              itemCount: snapshot.data!.all.length,
              itemBuilder: (context, index) {
                return Opacity(
                  opacity: widget.enableOpacityGradient
                      ? 1 - index / snapshot.data!.all.length
                      : 1,
                  child: widget.historyListItemLayoutBuilder?.call(
                          _inputHistoryController,
                          snapshot.data!.all[index],
                          index) ??
                      _listHistoryItem(snapshot.data!.all[index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _badgeHistoryItem(item) {
    return Container(
      height: 32,
      margin: EdgeInsets.only(right: 5, bottom: 5),
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
        color: _backgroundColor(item) ??
            // ignore: deprecated_member_use_from_same_package
            widget.badgeColor ??
            Theme.of(context).disabledColor.withAlpha(20),
        borderRadius: BorderRadius.all(Radius.circular(90)),
      ),
      child: InkWell(
        onTap: () async {
          _lastSubmitValue = item.text;
          await _inputHistoryController.select(item.text);
          widget.onHistoryItemSelected?.call(item.text);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// history icon
            if (widget.showHistoryIcon) _historyIcon(),

            /// text
            _historyItemText(item),

            /// remove icon
            if (widget.showDeleteIcon) _deleteIcon(item)
          ],
        ),
      ),
    );
  }

  Widget _backdrop(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          _focusNode.unfocus(); // Unfocus the text field if tapped outside
          await _toggleOverlayHistoryList();
        },
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _listHistoryItem(InputHistoryItem item) {
    return InkWell(
      onTap: () async {
        _lastSubmitValue = item.text;
        await _inputHistoryController.select(item.text);
        widget.onHistoryItemSelected?.call(item.text);
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        decoration: _listHistoryItemDecoration(item),
        child: Row(
          children: [
            /// history icon
            if (widget.showHistoryIcon) _historyIcon(),

            /// text
            _listHistoryItemText(item),

            /// remove icon
            if (widget.showDeleteIcon) _deleteIcon(item)
          ],
        ),
      ),
    );
  }

  Decoration? _listHistoryItemDecoration(InputHistoryItem item) {
    if (widget.listRowDecoration != null) return widget.listRowDecoration;
    if (widget.backgroundColor != null) {
      return BoxDecoration(color: _backgroundColor(item));
    }
    return null;
  }

  Widget _listHistoryItemText(InputHistoryItem item) {
    return Expanded(
      flex: 1,
      child: Container(
          margin: const EdgeInsets.only(left: 5.0),
          child: _historyItemText(item)),
    );
  }

  Widget _historyItemText(InputHistoryItem item) {
    return Text(_textToSingleLine.call(item.text),
        overflow: TextOverflow.ellipsis,
        style: widget.listTextStyle ??
            TextStyle(
                color: _textColor(item) ??
                    Theme.of(context).textTheme.bodyLarge!.color));
  }

  Color? _textColor(InputHistoryItem item) {
    if (item.isLock) return widget.lockTextColor;
    return widget.textColor;
  }

  Color? _backgroundColor(InputHistoryItem item) {
    if (item.isLock) return widget.lockBackgroundColor;
    return widget.backgroundColor;
  }

  Widget _historyIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: widget.historyIconTheme ??
          Icon(
            widget.historyIcon,
            size: 18,
            color: widget.historyIconColor ?? Theme.of(context).disabledColor,
          ),
    );
  }

  Widget _deleteIcon(InputHistoryItem item) {
    if (item.isLock) return SizedBox.shrink();
    return SizedBox(
      width: 22,
      height: 22,
      child: IconButton(
        padding: const EdgeInsets.all(0.0),
        color: Theme.of(context).disabledColor,
        icon: widget.deleteIconTheme ??
            Icon(
              widget.deleteIcon,
              size: 18,
              color: widget.deleteIconColor ?? Theme.of(context).disabledColor,
            ),
        onPressed: () {
          _inputHistoryController.remove(item);
        },
      ),
    );
  }

  void _onTap() {
    if (widget.textEditingController!.text != _lastSubmitValue &&
        _lastSubmitValue != null) {
      widget.onTap?.call();
    }
    _focusNode.requestFocus();
    if (widget.textEditingController == null) return;
    _toggleOverlayHistoryList();
  }

  String _defaultTextToSingleLine(String text) {
    return text.replaceAll("\n", "").replaceAll(" ", "");
  }

  Widget _textField() {
    return TextField(
        key: widget.key,
        controller: widget.textEditingController,
        focusNode: _focusNode,
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
        contextMenuBuilder: widget.contextMenuBuilder,
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
        // ignore: deprecated_member_use
        maxLengthEnforcement: widget.maxLengthEnforcement,
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
