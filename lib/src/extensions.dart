import 'package:flutter/material.dart';

extension StringExtensions on String {
  String get imagePath => 'lib/src/res/assets/$this';
}

extension MaterialPropX<T> on T {
  MaterialStateProperty<T> wrapMatProp() =>
      MaterialStateProperty.resolveWith<T>((states) => this);
}

extension MaterialColorPropX<Color> on Color {
  MaterialStateProperty<Color> wrapMatStateColor({
    required Color disabledColor,
  }) =>
      MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return disabledColor;
          } else {
            return this;
          }
        },
      );
}
