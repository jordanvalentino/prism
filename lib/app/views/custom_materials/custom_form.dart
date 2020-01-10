import 'package:flutter/material.dart';
import 'package:kilat/colors.dart' as colors;

class CustomTextFormField extends TextFormField {
  final bool obscureText;
  final bool readOnly;
  final String hintText;
  final String Function(String) validator;
  final void Function() onTap;
  final TextEditingController controller;
  final TextInputType keyboardType;

  CustomTextFormField({
    this.obscureText = false,
    this.readOnly = false,
    @required this.hintText,
    @required this.validator,
    this.onTap,
    this.controller,
    this.keyboardType = TextInputType.text,
  }) : super(
          style: TextStyle(
              color: colors.primary[800], fontWeight: FontWeight.w500),
          cursorColor: colors.primary[50],
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color: colors.primary[700], fontWeight: FontWeight.w400),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            enabledBorder: CustomUnderlineBorder(
                borderColor: colors.primary[50], borderWidth: 1),
            focusedBorder: CustomUnderlineBorder(
                borderColor: colors.primary[50], borderWidth: 2),
            focusedErrorBorder:
                CustomUnderlineBorder(borderColor: Colors.red, borderWidth: 2),
            errorBorder:
                CustomUnderlineBorder(borderColor: Colors.red, borderWidth: 1),
          ),
          obscureText: obscureText,
          readOnly: readOnly,
          validator: validator,
          onTap: onTap,
          controller: controller,
          keyboardType: keyboardType,
        );
}

class CustomUnderlineBorder extends UnderlineInputBorder {
  final Color borderColor;
  final double borderWidth;

  CustomUnderlineBorder(
      {@required this.borderColor, @required this.borderWidth})
      : super(borderSide: BorderSide(color: borderColor, width: borderWidth));
}

class CustomDropdownMenuItem extends DropdownMenuItem {
  final String text;
  final String value;

  CustomDropdownMenuItem({@required this.text, @required this.value})
      : super(
            value: value,
            child: Text(text,
                style: TextStyle(
                    color: colors.primary[800], fontWeight: FontWeight.w500)));
}

class IconCell extends TableCell {
  final IconData icon;
  IconCell({@required this.icon})
      : super(
          child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: Icon(icon),
          ),
          verticalAlignment: TableCellVerticalAlignment.top,
        );
}
