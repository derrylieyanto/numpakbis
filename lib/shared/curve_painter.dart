import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  final Color color;

  CurvePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    // TODO: Set properties to paint
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill

    // center of the canvas is (x,y) => (width/2, height/2)
    var center = Offset(size.width / 2, size.height / 2);

    var path = Path();
    // TODO: Draw your path
    path.moveTo((size.width/2)-2, 0);
    path.lineTo((size.width/2)+2, 0);
    path.lineTo((size.width/2)+2, size.height);
    path.lineTo((size.width/2)-2, size.height);
    path.lineTo((size.width/2)-2, 0);
    path.close();

    canvas.drawPath(path, paint);


    // draw the circle on centre of canvas having radius 75.0
    canvas.drawCircle(center, 10.0, paint);
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill; // Change this to fill
    canvas.drawCircle(center, 6.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}