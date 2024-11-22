import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:input_history_text_field/src/stream/input_history.dart';
import 'package:input_history_text_field/src/widget/input_history_text_field_state.dart';

import '../model/input_history_item.dart';

typedef HistoryListItemLayoutBuilder = Widget Function(
    InputHistoryController controller, InputHistoryItem value, int index);

enum ListStyle {
  List,
  Badge,
}

// ignore: must_be_immutable
class InputHistoryTextField extends StatefulWidget {
  final String historyKey;
  TextEditingController? textEditingController;
  FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final bool? showCursor;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final double? overlayHeight;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onHistoryItemSelected;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final DragStartBehavior dragStartBehavior;
  final bool enableInteractiveSelection;
  final GestureTapCallback? onTap;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final String Function(String)? textToSingleLine;

  /// max limit of input history
  final int limit;

  /// show input history of edit text focused
  final bool hasFocusExpand;

  /// icon of input history at left positioned
  final bool showHistoryIcon;

  /// icon of delete at right positioned
  final bool showDeleteIcon;

  // enabled/disabled of input history
  final bool enableHistory;

  /// show history list
  final bool showHistoryList;

  // enabled/disabled of filter history
  final bool enableFilterHistory;

  // enabled/disabled saved history
  final bool enableSave;

  /// make the input history list gradually transparent
  final bool enableOpacityGradient;

  /// IconData of delete icon.
  final IconData? deleteIcon;

  /// Size of delete icon.
  final double? deleteIconSize;

  /// IconData of delete icon.
  final IconData? historyIcon;

  /// Size of History icon.
  final double? historyIconSize;


  /// docoration of input history area
  final Decoration? listDecoration;

  /// offset of history list
  final Offset? listOffset;

  /// customize history icon
  final IconTheme? historyIconTheme;

  /// customize delete icon
  final IconTheme? deleteIconTheme;

  /// customize list text style
  final TextStyle? listTextStyle;

  /// customize list all
  final HistoryListItemLayoutBuilder? historyListItemLayoutBuilder;

  /// controller
  final InputHistoryController? inputHistoryController;

  /// style List or Badge
  final ListStyle? listStyle;

  /// font color
  final Color? textColor;

  /// Badge background color
  @Deprecated('use `backgroundColor` instead ')
  final Color? badgeColor;

  /// background color
  final Color? backgroundColor;

  /// history icon color
  final Color? historyIconColor;

  /// delete icon color
  final Color? deleteIconColor;

  final List<String>? lockItems;

  /// lock item background color
  final Color? lockBackgroundColor;

  /// lock item font color
  final Color? lockTextColor;

  final bool updateSelectedHistoryItemDateTime;

  InputHistoryTextField({
    Key? key,
    required this.historyKey,
    this.historyListItemLayoutBuilder,
    this.textToSingleLine,
    this.inputHistoryController,
    this.onHistoryItemSelected,
    this.limit = 5,
    this.hasFocusExpand = true,
    this.showHistoryIcon = true,
    this.showDeleteIcon = true,
    this.enableOpacityGradient = false,
    this.enableHistory = true,
    this.showHistoryList = true,
    this.enableFilterHistory = true,
    this.updateSelectedHistoryItemDateTime = false,
    this.enableSave = true,
    this.historyIcon = Icons.history,
    this.deleteIcon = Icons.close,
    this.listStyle = ListStyle.List,
    @Deprecated('use `backgroundColor` instead ') this.badgeColor,
    this.backgroundColor,
    this.textColor,
    this.historyIconColor,
    this.deleteIconColor,
    this.listDecoration,
    this.textEditingController,
    this.listOffset,
    this.lockItems,
    this.lockTextColor,
    this.overlayHeight,
    this.lockBackgroundColor,
    this.historyIconTheme,
    this.deleteIconTheme,
    this.listTextStyle,
    this.focusNode,
    this.decoration = const InputDecoration(),
    TextInputType? keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.showCursor,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement = MaxLengthEnforcement.none,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.deleteIconSize,
    this.historyIconSize,
  })  : smartDashesType = smartDashesType ??
            (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ??
            (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
        assert(
          (minLines == null) || (maxLines != null && (maxLines >= minLines)),
          "minLines can't be greater than maxLines",
        ),
        assert(
          !expands || (minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(maxLength == null ||
            maxLength == TextField.noMaxLength ||
            maxLength > 0),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        super(key: key);

  @override
  State<StatefulWidget> createState() => InputHistoryTextFieldState();

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }
}
