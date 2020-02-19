import 'package:flutter/material.dart';

class AtaButton extends StatefulWidget {
  final Function handler;
  final String label;

  AtaButton({this.handler, this.label = ''});

  @override
  _AtaButtonState createState() => _AtaButtonState();
}

class _AtaButtonState extends State<AtaButton> {
  bool _isLoading = false;

  void invokeHandler() async {
    setState(() {
      _isLoading = true;
    });
    await widget.handler();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: _isLoading
          ? SizedBox(
              child: CircularProgressIndicator(),
              height: 20.0,
              width: 20.0,
            )
          : Text(widget.label),
      onPressed: _isLoading ? null : invokeHandler,
    );
  }
}
