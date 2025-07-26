import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    this.onTap,
    required this.textBtn,
    required this.color,
    required this.icon,
  });

  final void Function()? onTap;
  final String textBtn;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(textBtn, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
