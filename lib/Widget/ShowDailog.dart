import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowDialog extends StatelessWidget {
  final Function firstPress;
  final Function secondPress;

  ShowDialog({@required this.firstPress,@required this.secondPress});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Select Options'),
      actions: <Widget>[
        TextButton(child: Text('Camera'), onPressed: firstPress),
        TextButton(child: Text('Gallary'), onPressed: secondPress),
      ],
    );
  }
}
