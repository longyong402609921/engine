// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of dart.ui;

/// The possible actions that can be conveyed from the operating system
/// accessibility APIs to a semantics node.
class SemanticsAction {
  const SemanticsAction._(this.index);

  static const int _kTapIndex = 1 << 0;
  static const int _kLongPressIndex = 1 << 1;
  static const int _kScrollLeftIndex = 1 << 2;
  static const int _kScrollRightIndex = 1 << 3;
  static const int _kScrollUpIndex = 1 << 4;
  static const int _kScrollDownIndex = 1 << 5;
  static const int _kIncreaseIndex = 1 << 6;
  static const int _kDecreaseIndex = 1 << 7;
  static const int _kShowOnScreen = 1 << 8;
  static const int _kMoveCursorForwardByCharacter = 1 << 9;
  static const int _kMoveCursorBackwardByCharacter = 1 << 10;

  /// The numerical value for this action.
  ///
  /// Each action has one bit set in this bit field.
  final int index;

  /// The equivalent of a user briefly tapping the screen with the finger
  /// without moving it.
  static const SemanticsAction tap = const SemanticsAction._(_kTapIndex);

  /// The equivalent of a user pressing and holding the screen with the finger
  /// for a few seconds without moving it.
  static const SemanticsAction longPress = const SemanticsAction._(_kLongPressIndex);

  /// The equivalent of a user moving their finger across the screen from right
  /// to left.
  ///
  /// This action should be recognized by controls that are horizontally
  /// scrollable.
  static const SemanticsAction scrollLeft = const SemanticsAction._(_kScrollLeftIndex);

  /// The equivalent of a user moving their finger across the screen from left
  /// to right.
  ///
  /// This action should be recognized by controls that are horizontally
  /// scrollable.
  static const SemanticsAction scrollRight = const SemanticsAction._(_kScrollRightIndex);

  /// The equivalent of a user moving their finger across the screen from
  /// bottom to top.
  ///
  /// This action should be recognized by controls that are vertically
  /// scrollable.
  static const SemanticsAction scrollUp = const SemanticsAction._(_kScrollUpIndex);

  /// The equivalent of a user moving their finger across the screen from top
  /// to bottom.
  ///
  /// This action should be recognized by controls that are vertically
  /// scrollable.
  static const SemanticsAction scrollDown = const SemanticsAction._(_kScrollDownIndex);

  /// A request to increase the value represented by the semantics node.
  ///
  /// For example, this action might be recognized by a slider control.
  static const SemanticsAction increase = const SemanticsAction._(_kIncreaseIndex);

  /// A request to decrease the value represented by the semantics node.
  ///
  /// For example, this action might be recognized by a slider control.
  static const SemanticsAction decrease = const SemanticsAction._(_kDecreaseIndex);

  /// A request to fully show the semantics node on screen.
  ///
  /// For example, this action might be send to a node in a scrollable list that
  /// is partially off screen to bring it on screen.
  static const SemanticsAction showOnScreen = const SemanticsAction._(_kShowOnScreen);


  /// Move the cursor forward by one character.
  ///
  /// This is for example used by the cursor control in text fields.
  static const SemanticsAction moveCursorForwardByCharacter = const SemanticsAction._(_kMoveCursorForwardByCharacter);

  /// Move the cursor backward by one character.
  ///
  /// This is for example used by the cursor control in text fields.
  static const SemanticsAction moveCursorBackwardByCharacter = const SemanticsAction._(_kMoveCursorBackwardByCharacter);

  /// The possible semantics actions.
  ///
  /// The map's key is the [index] of the action and the value is the action
  /// itself.
  static final Map<int, SemanticsAction> values = const <int, SemanticsAction>{
    _kTapIndex: tap,
    _kLongPressIndex: longPress,
    _kScrollLeftIndex: scrollLeft,
    _kScrollRightIndex: scrollRight,
    _kScrollUpIndex: scrollUp,
    _kScrollDownIndex: scrollDown,
    _kIncreaseIndex: increase,
    _kDecreaseIndex: decrease,
    _kShowOnScreen: showOnScreen,
    _kMoveCursorForwardByCharacter: moveCursorForwardByCharacter,
    _kMoveCursorBackwardByCharacter: moveCursorBackwardByCharacter,
  };

  @override
  String toString() {
    switch (index) {
      case _kTapIndex:
        return 'SemanticsAction.tap';
      case _kLongPressIndex:
        return 'SemanticsAction.longPress';
      case _kScrollLeftIndex:
        return 'SemanticsAction.scrollLeft';
      case _kScrollRightIndex:
        return 'SemanticsAction.scrollRight';
      case _kScrollUpIndex:
        return 'SemanticsAction.scrollUp';
      case _kScrollDownIndex:
        return 'SemanticsAction.scrollDown';
      case _kIncreaseIndex:
        return 'SemanticsAction.increase';
      case _kDecreaseIndex:
        return 'SemanticsAction.decrease';
      case _kShowOnScreen:
        return 'SemanticsAction.showOnScreen';
      case _kMoveCursorForwardByCharacter:
        return 'SemanticsAction.moveCursorForwardByCharacter';
      case _kMoveCursorBackwardByCharacter:
        return 'SemanticsAction.moveCursorBackwardByCharacter';
    }
    return null;
  }
}

/// A Boolean value that can be associated with a semantics node.
class SemanticsFlags {
  static const int _kHasCheckedStateIndex = 1 << 0;
  static const int _kIsCheckedIndex = 1 << 1;
  static const int _kIsSelectedIndex = 1 << 2;
  static const int _kIsButtonIndex = 1 << 3;
  static const int _kIsTextFieldIndex = 1 << 4;
  static const int _kIsFocusedIndex = 1 << 5;

  const SemanticsFlags._(this.index);

  /// The numerical value for this flag.
  ///
  /// Each flag has one bit set in this bit field.
  final int index;

  /// The semantics node has the quality of either being "checked" or "unchecked".
  ///
  /// For example, a checkbox or a radio button widget has checked state.
  static const SemanticsFlags hasCheckedState = const SemanticsFlags._(_kHasCheckedStateIndex);

  /// Whether a semantics node that [hasCheckedState] is checked.
  ///
  /// If true, the semantics node is "checked". If false, the semantics node is
  /// "unchecked".
  ///
  /// For example, if a checkbox has a visible checkmark, [isChecked] is true.
  static const SemanticsFlags isChecked = const SemanticsFlags._(_kIsCheckedIndex);


  /// Whether a semantics node is selected.
  ///
  /// If true, the semantics node is "selected". If false, the semantics node is
  /// "unselected".
  ///
  /// For example, the active tab in a tab bar has [isSelected] set to true.
  static const SemanticsFlags isSelected = const SemanticsFlags._(_kIsSelectedIndex);

  /// Whether the semantic node represents a button.
  ///
  /// Platforms has special handling for buttons, for example Android's TalkBack
  /// and iOS's VoiceOver provides an additional hint when the focused object is
  /// a button.
  static const SemanticsFlags isButton = const SemanticsFlags._(_kIsButtonIndex);

  /// Whether the semantic node represents a text field.
  ///
  /// Text fields are announced as such and allow text input via accessibility
  /// affordances.
  static const SemanticsFlags isTextField = const SemanticsFlags._(_kIsTextFieldIndex);

  /// Whether the semantic node currently holds the user's focus.
  ///
  /// The focused element is usually the current receiver of keyboard inputs.
  static const SemanticsFlags isFocused = const SemanticsFlags._(_kIsFocusedIndex);

  /// The possible semantics flags.
  ///
  /// The map's key is the [index] of the flag and the value is the flag itself.
  static final Map<int, SemanticsFlags> values = const <int, SemanticsFlags>{
    _kHasCheckedStateIndex: hasCheckedState,
    _kIsCheckedIndex: isChecked,
    _kIsSelectedIndex: isSelected,
    _kIsButtonIndex: isButton,
    _kIsTextFieldIndex: isTextField,
    _kIsFocusedIndex: isFocused,
  };

  @override
  String toString() {
    switch (index) {
      case _kHasCheckedStateIndex:
        return 'SemanticsFlags.hasCheckedState';
      case _kIsCheckedIndex:
        return 'SemanticsFlags.isChecked';
      case _kIsSelectedIndex:
        return 'SemanticsFlags.isSelected';
      case _kIsButtonIndex:
        return 'SemanticsFlags.isButton';
      case _kIsTextFieldIndex:
        return 'SemanticsFlags.isTextField';
      case _kIsFocusedIndex:
        return 'SemanticsFlags.isFocused';
    }
    return null;
  }
}

/// An object that creates [SemanticsUpdate] objects.
///
/// Once created, the [SemanticsUpdate] objects can be passed to
/// [Window.updateSemantics] to update the semantics conveyed to the user.
class SemanticsUpdateBuilder extends NativeFieldWrapperClass2 {
  /// Creates an empty [SemanticsUpdateBuilder] object.
  SemanticsUpdateBuilder() { _constructor(); }
  void _constructor() native "SemanticsUpdateBuilder_constructor";

  /// Update the information associated with the node with the given `id`.
  ///
  /// The semantics nodes form a tree, with the root of the tree always having
  /// an id of zero. The `children` are the ids of the nodes that are immediate
  /// children of this node. The system retains the nodes that are currently
  /// reachable from the root. A given update need not contain information for
  /// nodes that do not change in the update. If a node is not reachable from
  /// the root after an update, the node will be discarded from the tree.
  ///
  /// The `flags` are a bit field of [SemanticsFlags] that apply to this node.
  ///
  /// The `actions` are a bit field of [SemanticsAction]s that can be undertaken
  /// by this node. If the user wishes to undertake one of these actions on this
  /// node, the [Window.onSemanticsAction] will be called with `id` and one of
  /// the possible [SemanticsAction]s. Because the semantics tree is maintained
  /// asynchronously, the [Window.onSemanticsAction] callback might be called
  /// with an action that is no longer possible.
  ///
  /// The `label` is a string that describes this node. The `value` property
  /// describes the current value of the node as a string. The `increasedValue`
  /// string will become the `value` string after a [SemanticsAction.increase]
  /// action is performed. The `decreasedValue` string will become the `value`
  /// string after a [SemanticsAction.decrease] action is performed. The `hint`
  /// string describes what result an action performed on this node has. The
  /// reading direction of all these strings is given by `textDirection`.
  ///
  /// The `rect` is the region occupied by this node in its own coordinate
  /// system.
  ///
  /// The `transform` is a matrix that maps this node's coodinate system into
  /// its parent's coordinate system.
  void updateNode({
    int id,
    int flags,
    int actions,
    Rect rect,
    String label,
    String hint,
    String value,
    String increasedValue,
    String decreasedValue,
    TextDirection textDirection,
    Float64List transform,
    Int32List children
  }) {
    if (transform.length != 16)
      throw new ArgumentError('transform argument must have 16 entries.');
    _updateNode(id,
                flags,
                actions,
                rect.left,
                rect.top,
                rect.right,
                rect.bottom,
                label,
                hint,
                value,
                increasedValue,
                decreasedValue,
                textDirection != null ? textDirection.index + 1 : 0,
                transform,
                children);
  }
  void _updateNode(
    int id,
    int flags,
    int actions,
    double left,
    double top,
    double right,
    double bottom,
    String label,
    String hint,
    String value,
    String increasedValue,
    String decreasedValue,
    int textDirection,
    Float64List transform,
    Int32List children
  ) native "SemanticsUpdateBuilder_updateNode";

  /// Creates a [SemanticsUpdate] object that encapsulates the updates recorded
  /// by this object.
  ///
  /// The returned object can be passed to [Window.updateSemantics] to actually
  /// update the semantics retained by the system.
  SemanticsUpdate build() native "SemanticsUpdateBuilder_build";
}

/// An opaque object representing a batch of semantics updates.
///
/// To create a SemanticsUpdate object, use a [SemanticsUpdateBuilder].
///
/// Semantics updates can be applied to the system's retained semantics tree
/// using the [Window.updateSemantics] method.
class SemanticsUpdate extends NativeFieldWrapperClass2 {
  /// Creates an uninitialized SemanticsUpdate object.
  ///
  /// Calling the SemanticsUpdate constructor directly will not create a useable
  /// object. To create a SemanticsUpdate object, use a [SemanticsUpdateBuilder].
  SemanticsUpdate(); // (this constructor is here just so we can document it)

  /// Releases the resources used by this semantics update.
  ///
  /// After calling this function, the semantics update is cannot be used
  /// further.
  void dispose() native "SemanticsUpdateBuilder_dispose";
}
