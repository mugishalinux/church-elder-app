import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Day extends StatelessWidget {
  final double top;
  final double left;
  final double right;
  final double bottom;
  final Color color;
  final double radius;
  final bool isCurrentDate;
  final bool isOval;
  final double width;
  final double height;
  final int id;
  final int day;

  const Day(
      {Key? key,
      required this.top,
      required this.left,
      required this.right,
      required this.bottom,
      required this.color,
      required this.radius,
      required this.isCurrentDate,
      required this.isOval,
      required this.width,
      required this.height,
      required this.id,
      require,
      required this.day})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color containerColor = day == id ? Colors.green : color;

    return Positioned(
      top: top == 0 ? null : top,
      left: left == 0 ? null : left,
      right: right == 0 ? null : right,
      bottom: bottom == 0 ? null : bottom,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(radius / 360),
        child: Stack(alignment: Alignment.center, children: [
          Container(
            key: ValueKey(id),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: isOval
                  ? const BorderRadius.all(Radius.elliptical(20, 10))
                  : null,
              border: Border.all(
                color: Colors.black, // Change the color as needed
                width: 2, // Change the width as needed
              ),
            ),
          ),
          if (day == id)
            Positioned(
              top: -width / 2,
              child: const RingDesign(),
            ),
        ]),
      ),
    );
  }
}

class RingDesign extends StatelessWidget {
  const RingDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(
          color: Colors.green,
          width: 4,
        ),
      ),
    );
  }
}
