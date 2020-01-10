import 'dart:io';

import 'package:flutter/material.dart';

void alertDialog(BuildContext context, String content,
    {String title = 'Info', Function onConfirm}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: onConfirm ??
                  () {
                    Navigator.pop(context);
                  },
            )
          ],
        );
      });
}

void confirmDialog(BuildContext context, String content,
    {String title = 'Info', Function onCancel, Function onConfirm}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: onCancel ??
                  () {
                    Navigator.pop(context);
                  },
            ),
            FlatButton(
              child: Text("Confirm"),
              onPressed: onConfirm ??
                  () {
                    Navigator.pop(context);
                  },
            )
          ],
        );
      });
}

void yesNoDialog(BuildContext context, String content,
    {String title = 'Info', Function onNo, Function onYes}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: onNo ??
                  () {
                    Navigator.pop(context);
                  },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: onYes ??
                  () {
                    Navigator.pop(context);
                  },
            )
          ],
        );
      });
}

void errorDialog(BuildContext context, String e) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
        );
      });
}

String socketExceptionMessage(SocketException e) {
  switch (e.osError.errorCode) {
    case 101:
      return 'Cannot connect to network.';
      break;
    case 111:
      return 'Cannot connect to server.';
      break;
    default:
      return 'Service unavailable.';
      break;
  }
}
