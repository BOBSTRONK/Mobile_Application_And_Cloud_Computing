import 'package:flutter/material.dart';

class TopScreenImage extends StatelessWidget {
  const TopScreenImage({super.key, required this.screenImageName});
  final String screenImageName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/$screenImageName'),
          ),
        ),
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.buttonText,
      this.isOutlined = false,
      required this.onPressed,
      this.width = 280});

  final String buttonText;
  final bool isOutlined;
  final Function onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 4,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : Color(0xFF4879C5),
            border: Border.all(color: Color(0xFF4879C5), width: 2.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isOutlined ? Color(0xFF4879C5) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final Function? press;
  const AlreadyHaveAnAccountCheck({
    Key? key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? "Don't have an Account? " : "Already have an Account? ",
          style: const TextStyle(color: Colors.black),
        ),
        GestureDetector(
          // type cast, it ensures that 'press' is being treated as function that takes no parameters
          onTap: press as void Function()?,
          child: Text(
            login ? "Sign Up" : "Sign In",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}

class RoundedCornerImage extends StatelessWidget {
  final Offset imageOffset;
  final String asset;
  final double scale;

  const RoundedCornerImage({
    super.key,
    required this.asset,
    this.imageOffset = Offset.zero,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(40),
      ),
      child: Transform.translate(
        offset: imageOffset,
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            asset,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class CurvedCornerContainer extends StatelessWidget {
  final Widget? child;
  final double minHeight;
  final double maxHeight;

  const CurvedCornerContainer({
    super.key,
    this.child,
    this.minHeight = 260,
    this.maxHeight = 380,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FancyClipPath(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: minHeight,
          maxHeight: maxHeight,
        ),
        color: Colors.white,
        child: child,
      ),
    );
  }
}

class FancyClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 48.0;
    Path path = Path();
    path.moveTo(0, radius * 2);
    path.arcToPoint(
      const Offset(radius, radius),
      radius: const Radius.circular(
        radius,
      ),
    );
    path.lineTo(size.width - radius, radius);
    path.arcToPoint(
      Offset(size.width, 0),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class DescriptionContent extends StatelessWidget {
  final String productTitle;
  final String brand;
  final String description;

  const DescriptionContent({
    super.key,
    required this.productTitle,
    required this.brand,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 14,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productTitle,
            style: TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            brand,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0, bottom: 10),
            child: Text(
              description,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Text(
            "Please enter the CD Key to become a Publisher!",
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }
}

class ButtonsBar extends StatelessWidget {
  final String BecomePublisherButtonText;
  final Function() onBecomePublisherButtonTapped;

  const ButtonsBar({
    Key? key,
    required this.BecomePublisherButtonText,
    required this.onBecomePublisherButtonTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 8,
          bottom: 32,
        ),
        child: Row(
          children: [
            Expanded(
              child: BecomePublisherButton(
                buttonText: BecomePublisherButtonText,
                onTap: onBecomePublisherButtonTapped,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BecomePublisherButton extends StatelessWidget {
  final String buttonText;
  final Function() onTap;

  const BecomePublisherButton({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 54,
      color: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Text(
        buttonText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
