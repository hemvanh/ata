import 'package:flutter/material.dart';

class AtaTextField extends StatelessWidget {
  final String label;
  final TextInputType type;
  final String initialValue;
  final TextEditingController controller;

  AtaTextField({this.label, this.type = TextInputType.text, this.initialValue, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: type,
      initialValue: initialValue,
      controller: controller,
    );
  }
}
