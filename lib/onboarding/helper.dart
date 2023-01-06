import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocationweather/homepage/Homepage.dart';
import 'package:geolocationweather/widget/textwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ignore: camel_case_types
class onboarding extends StatefulWidget {
  const onboarding({super.key});

  @override
  State<onboarding> createState() => _onboardingState();
}

List<String> topic = [
  "WELCOME",
  "SEARCH LOCATION",
  "AUTOMATICALLY DETECT THE LOCATION",
  "ENJOY OUR APP"
];
List<String> content = [
  "We show weather for you",
  "Get details of weather of any place",
  "Automatically get the weather info of your current location",
  "FEEL EASE TO USE OUR APP"
];

class _onboardingState extends State<onboarding> {
  final controller = CarouselController();
  bool islastpage = false;
  bool isfirstpage = true;
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarouselSlider(
        carouselController: controller,
        options: CarouselOptions(
            onPageChanged: (index, reason) async {
              setState(() {
                activeIndex = index;
                islastpage = index == 3;
              });
              if (islastpage) {
                final preload = await SharedPreferences.getInstance();
                preload.setBool("firsttime", false);
                await Future.delayed(const Duration(seconds: 5));
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => Homepage()));
              }
            },
            enableInfiniteScroll: false,
            pageSnapping: true,
            autoPlay: !islastpage,
            height: MediaQuery.of(context).size.height - 60,
            autoPlayInterval: const Duration(seconds: 5),
            viewportFraction: 1),
        items: [
          Container(
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                image: const DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.cover)),
            width: double.infinity,
            // color: Colors.transparent,
            child: const TextWidget(
                topic: "WELCOME", content: "We show weather for you"),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                image: const DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.cover)),
            width: double.infinity,
            // color: ,
            child: const TextWidget(
                topic: "SEARCH LOCATION",
                content: "Get details of weather of any place"),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                image: const DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.cover)),
            width: double.infinity,
            //color: Colors.pinkAccent,
            child: const TextWidget(
                topic: "AUTOMATICALLY DETECT THE LOCATION",
                content:
                    "Automatically get the weather info of your current location"),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                image: const DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.cover)),
            width: double.infinity,
            //color: Colors.purpleAccent,
            child: const TextWidget(
                topic: "ENJOY OUR APP", content: "FEEL EASE TO USE OUR APP"),
          ),
        ],
      ),
      //  PageView(
      //   controller: controller,
      //   onPageChanged: (value) async {
      //     setState(() {
      //       islastpage = value == 3;
      //     });
      //     controller.initialPage;
      //     await Future.delayed(const Duration(seconds: 5));

      //     if (islastpage) {
      //       // ignore: use_build_context_synchronously
      //       Navigator.pushReplacement(
      //           context, MaterialPageRoute(builder: (context) => Homepage()));
      //     } else {
      //       controller.nextPage(
      //           duration: const Duration(milliseconds: 1),
      //           curve: Curves.easeIn);
      //     }
      //   },
      //   children: [

      //   ],
      // ),
      bottomSheet: SizedBox(
        height: 55,
        child: islastpage
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final preload = await SharedPreferences.getInstance();
                    preload.setBool("firsttime", false);
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => Homepage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text("GET STARTED"),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () => controller.jumpToPage(3),
                      child: const Text("SKIP",
                          style: TextStyle(color: Colors.teal))),
                  Center(
                    child: AnimatedSmoothIndicator(
                        activeIndex: activeIndex, count: 4),
                  ),
                  TextButton(
                      onPressed: () => controller.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInToLinear),
                      child: const Text(
                        "NEXT>",
                        style: TextStyle(color: Colors.teal),
                      ))
                ],
              ),
      ),
    );
  }
}
