import 'package:flutter/material.dart';
class SquareTile extends StatelessWidget {
  final String imagePath;
  final Function() onPressed;

  const SquareTile({
    Key? key,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Image.asset(
          imagePath,
          height: 40,
        ),
      ),
    );
  }
}