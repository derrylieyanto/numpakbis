import 'package:flutter/material.dart';

class LoadingLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child:  Container(
          width: 250,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/numpakbis.png'),
                fit: BoxFit.fill,
              ),
            ),
        ),
      ),
    );
  }
}
