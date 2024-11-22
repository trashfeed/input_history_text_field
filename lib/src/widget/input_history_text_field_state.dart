import 'package:flutter/material.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:input_history_text_field/src/model/input_history_item.dart';
import 'package:input_history_text_field/src/model/input_history_items.dart';

class InputHistoryTextFieldState extends State<InputHistoryTextField> {
  late InputHistoryController _inputHistoryController;
  late String Function(String) _textToSingleLine;
  late FocusNode _focusNode;
  final GlobalKey _overlayHistoryListKey = GlobalKey();
  OverlayEntry? _overlayHistoryList;
  String? _lastSubmitValue;

  @override
  void initState() {
    super.initState();
    _initWidgetState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant InputHistoryTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-initialize state if needed after hot reload
    if (widget.textEditingController == null) {
      widget.textEditingController =
          TextEditingController(text: _lastSubmitValue);
    }
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
      if (!_inputHistoryController.isShown()) {
        _inputHistoryController.toggleExpand();
      }
    } else {
      _inputHistoryController.hide();
    }
  }

  void _initOverlay() {
    _overlayHistoryList = _historyListContainer();
    Overlay.of(context).insert(_overlayHistoryList!);
  }

  OverlayEntry _historyListContainer() {
    final renderBox = context.findRenderObject() as RenderBox;
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
                _historyList(context, renderBox, shown.data!),
              ],
            );
          },
        );
      },
    );
  }

  Decoration _listDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withOpacity(0.25),
          offset: Offset(0, 1), // Slight downward offset
          blurRadius: 1.5,
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withOpacity(0.25),
          offset: Offset(0, 2), // Larger downward offset
          blurRadius: 5,
        ),
      ],
    );
  }

  Widget _historyList(BuildContext context, RenderBox render, bool isShow) {
    final offset = render.localToGlobal(Offset.zero);
    final listOffset = widget.listOffset ?? Offset(0, 0);

    return Positioned(
      key: _overlayHistoryListKey,
      top: offset.dy +
          render.size.height +
          (widget.listStyle == ListStyle.Badge
              ? listOffset.dy + 10
              : listOffset.dy),
      left: offset.dx + listOffset.dx,
      width: isShow
          ? widget.listStyle == ListStyle.List
              ? render.size.width
              : null
          : null,
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
              spacing: 8,
              children: [
                for (var item in snapshot.data!.all) _badgeHistoryItem(item)
              ],
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
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
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        ),
      ),
      onPressed: () async {
        _lastSubmitValue = item.text;
        await _inputHistoryController.select(item.text);
        widget.onHistoryItemSelected?.call(item.text);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// history icon
          if (widget.showHistoryIcon) _historyIcon(),
          if (widget.showHistoryIcon) SizedBox(width: 4),

          /// text
          _historyItemText(item),

          /// delete icon
          if (widget.showDeleteIcon) SizedBox(width: 4),
          if (widget.showDeleteIcon) _deleteIcon(item)
        ],
      ),
    );
  }

  Widget _listHistoryItem(InputHistoryItem item) {
    return Material(
      color: Colors.transparent, // Make Material background transparent
      child: ListTile(
        
        tileColor: _backgroundColor(item),
        onTap: () async {
          _lastSubmitValue = item.text;
          await _inputHistoryController.select(item.text);
          widget.onHistoryItemSelected?.call(item.text);
        },
        leading: widget.showHistoryIcon ? _historyIcon() : null,
        trailing: widget.showDeleteIcon ? _deleteIcon(item) : null,
        title: _historyItemText(item),
      ),
    );
  }

  Widget _historyItemText(InputHistoryItem item) {
    return Text(
      _textToSingleLine.call(item.text),
      overflow: TextOverflow.ellipsis,
      style: widget.listTextStyle ??
          TextStyle(
            color: _textColor(item),
          ),
    );
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
    return widget.historyIconTheme ??
        Icon(
          widget.historyIcon,
          size: widget.historyIconSize ?? 24,
          color: widget.historyIconColor,
        );
  }

  Widget _deleteIcon(InputHistoryItem item) {
    if (item.isLock) return SizedBox.shrink();
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tight(
        Size(
          widget.deleteIconSize ?? 24,
          widget.deleteIconSize ?? 24,
        ),
      ),
      visualDensity: VisualDensity.compact,
      icon: widget.deleteIconTheme ??
          Icon(
            widget.deleteIcon,
            size: widget.deleteIconSize ?? 24,
            color: widget.deleteIconColor,
          ),
      onPressed: () {
        _inputHistoryController.remove(item);
      },
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
        onTapOutside: (event) async {
          RenderBox? overlayBox = _overlayHistoryListKey.currentContext
              ?.findRenderObject() as RenderBox?;
          RenderBox? renderBox = context.findRenderObject() as RenderBox?;

          if (overlayBox != null && renderBox != null) {
            // Convert the tap's local position to global position
            // Get the global position of the tap event
            Offset globalTapPosition = event.position;

            // Get the global position and size of the overlay entry
            Offset overlayPosition = overlayBox.localToGlobal(Offset.zero);
            Size overlaySize = overlayBox.size;

            // Check if the tap is within the overlay bounds
            bool tappedOutside = !(globalTapPosition.dx >= overlayPosition.dx &&
                globalTapPosition.dx <=
                    overlayPosition.dx + overlaySize.width &&
                globalTapPosition.dy >= overlayPosition.dy &&
                globalTapPosition.dy <=
                    overlayPosition.dy + overlaySize.height);
           
            // If tapped outside the overlay, close the overlay
            if (tappedOutside) {
              _focusNode.unfocus();
              _inputHistoryController.hide();
            }
          } else {
            _focusNode.unfocus();
            _inputHistoryController.hide();
          }
        },
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
