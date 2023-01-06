import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocationweather/homepage/Homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding/helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final predata = await SharedPreferences.getInstance();
  bool isFirstTime = predata.getBool("firsttime") ?? true;
  runApp(ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isFirstTime ? const onboarding() : Homepage(),
    ),
  ));
}
