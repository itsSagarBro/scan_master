import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:scan_master/utils/text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "About",
          style: appBarHeading(),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  "Rate Now",
                  style: defaultTextStyle(fontSize: 14),
                ),
                onTap: () => LaunchReview.launch(
                    androidAppId: 'com.untitledstudio.scan_master'),
              ),
            ],
            position: PopupMenuPosition.under,
            enableFeedback: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 150,
              child: Center(
                child: ClipOval(
                  child: Image.asset("assets/play_store_512.png"),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Scan Master",
              style:
                  defaultTextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.',
              textAlign: TextAlign.center,
              style: defaultTextStyle(fontSize: 14),
            ),
            const Divider(
              height: 30,
            ),
            Text(
              "Developed by Sagar Patel",
              style: defaultTextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
