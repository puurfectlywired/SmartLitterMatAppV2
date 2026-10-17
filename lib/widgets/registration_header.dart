
import 'package:flutter/material.dart';


///////////////////////////////////////////REGISTRATION HEADER/////////////////////////////
class RegistrationHeader extends StatelessWidget {
  const RegistrationHeader({
    super.key,
    this.progress = 0.25,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      width: double.infinity,

      child: Stack(
        clipBehavior: Clip.none,
        children: [

          // CURVED BACKGROUND
          ClipPath(
            clipper: HeaderCurveClipper(),
            child: Container(
              height: 175,
              width: double.infinity,
              color: colors.primary,
            ),
          ),

          // BACK ARROW
          Positioned(
            top: 20,
            left: 15,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: colors.onPrimary,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // CAT IMAGE
          Positioned(
            top: 65,
            right: 25,
            child: Image.asset(
              'assets/images/cat_header.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),

          // PROGRESS BAR
          Positioned(
            top: 195,
            left: 25,
            right: 25,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CURVED BACKGROUND SHAPE
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height * 0.85);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.45,
      size.width,
      size.height * 0.85,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
