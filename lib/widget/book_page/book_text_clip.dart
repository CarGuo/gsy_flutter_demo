import 'package:flutter/material.dart';

class BookTextClip extends CustomClipper<Path> {
  final Path path;

  BookTextClip(this.path);

  @override
  Path getClip(Size size) {
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
