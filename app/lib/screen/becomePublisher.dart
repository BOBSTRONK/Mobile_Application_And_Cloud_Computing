import 'package:app/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BecomePublisherPage extends StatefulWidget {
  const BecomePublisherPage({super.key});

  @override
  State<BecomePublisherPage> createState() => _BecomePublisherPageState();
}

class _BecomePublisherPageState extends State<BecomePublisherPage> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController cdKeyController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      bottomNavigationBar: ButtonsBar(
        BecomePublisherButtonText: "Become a Publisher",
        onBecomePublisherButtonTapped: () {},
      ),
      body: Padding(
        padding: EdgeInsets.all(6),
        child: Stack(
          children: [
            Positioned.fill(
              child: RoundedCornerImage(
                asset:
                    'assets/images/ActiveMinds_VoteEarlyDay_Banner_1200x535_V1.webp',
                scale: 1.25,
                imageOffset: Offset(0, 120),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: CurvedCornerContainer(
                child: DescriptionContent(
                  productTitle: 'Become a Publisher',
                  brand: 'Why?',
                  description:
                      'By becoming a publisher, you can Publish Vote event without need of A wallet or Ethereum, You can use our fund!',
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Form(
                    key: _formkey,
                    child: TextFormField(
                      cursorColor: Colors.black,
                      controller: cdKeyController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the CD key";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "CD Key",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(Icons.key_sharp),
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
