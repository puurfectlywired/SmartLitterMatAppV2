
import 'package:flutter/material.dart';
import '../theme/app_colours.dart';

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
    final appColors = Theme.of(context).extension<AppColors>()!;

    return SizedBox(
      height: 175,
      width: double.infinity,

      child: Stack(
        children: [

          // CURVED BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,

            child: ClipPath(
              clipper: HeaderCurveClipper(),

              child: ColoredBox(
                color: appColors.registrationHeader,
              ),
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
              'assets/images/PUUR_V4.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              cacheWidth: 300,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('CAT IMAGE ERROR: $error');
                return const SizedBox(
                  width: 100,
                  height: 100,
                  child: Icon(Icons.pets),
                );
              },
            ),
          ),

          // PROGRESS BAR
          Positioned(
            bottom: 30,
            left: 25,
            right: 25,

            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                appColors.registrationProgress,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////CURVED HEADER SHAPE/////////////////////////////
class HeaderCurveClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.45,
        size.width,
        size.height * 0.85,
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
