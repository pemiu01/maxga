import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class FormItem extends ChangeNotifier {
  final TextEditingController controller;
  bool isDirty = false;
  String errorText;

  List<FormFieldValidator<FormItem>> _validators = [];

  String get value => this.controller?.text ?? "";

  bool get invalid => isDirty && this.errorText != null;
  bool get valid => !invalid;
  bool get isEmpty => this.value == "";

  FormItem({
    String text,
    List<FormFieldValidator<FormItem>> validators,
  }) : this.controller = TextEditingController(text: text) {
    this.controller.addListener(() {
      if (!isEmpty) {
        this.isDirty = true;
      }
    });
    this.controller.addListener(validateValue);
    this._validators.addAll(validators ?? []);
  }


  setError(String error) {
    this.isDirty = true;
    this.errorText = error;
    this.notifyListeners();
  }

  clearError() {
    this.errorText = null;
    this.notifyListeners();
  }

  addValidator(FormFieldValidator<FormItem> validator) {
    _validators.add(validator);
  }

  void validateValue() {
    if (_validators.length == 0) {
      return null;
    }
    if (!isDirty) {
      return null;
    }
    for (var validator in _validators) {
      String errorText = validator(this);
      if (errorText != null) {
        return this.setError(errorText);
      }
    }
    this.clearError();
  }
}
