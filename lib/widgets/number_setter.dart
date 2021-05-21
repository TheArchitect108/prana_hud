import 'package:flutter/material.dart';

class NumberSetter extends StatefulWidget {
  dynamic value;
  Function onDecrement;
  Function onIncrement;
  bool showDecrement;
  bool showIncrement;
  NumberSetter(
      {Key key,
      this.value,
      this.onDecrement,
      this.onIncrement,
      this.showDecrement = true,
      this.showIncrement = true})
      : super(key: key);

  @override
  _NumberSetterState createState() => _NumberSetterState();
}

class _NumberSetterState extends State<NumberSetter> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.showDecrement
            ? GestureDetector(
                onTap: widget.onDecrement,
                child: Icon(
                  Icons.arrow_left,
                  color: Theme.of(context).accentColor,
                ))
            : Container(width: 20),
        Text(
          widget.value.runtimeType == "".runtimeType
              ? widget.value
              : widget.value.toString(),
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        widget.showIncrement
            ? GestureDetector(
                child: Icon(
                  Icons.arrow_right,
                  color: Theme.of(context).accentColor,
                ),
                onTap: widget.onIncrement,
              )
            : Container(width: 20),
      ],
    );
  }
}
