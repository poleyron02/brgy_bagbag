import 'package:flutter/material.dart';

class ListNotifier<T extends dynamic> extends ValueNotifier<List<T>> {
  ListNotifier(super.value);

  void add(T item) {
    value.add(item);
    notifyListeners();
  }

  bool remove(T item) {
    bool result = value.remove(item);
    notifyListeners();
    return result;
  }

  void clear() {
    value.clear();
    notifyListeners();
  }
}
