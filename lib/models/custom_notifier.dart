import 'package:flutter/material.dart';

class CustomNotifier<T extends dynamic> extends ValueNotifier<T?> {
  CustomNotifier(super.value);

  void set(T item) {
    value = item;
    notifyListeners();
  }

  void remove() {
    value = null;
    notifyListeners();
  }
}
