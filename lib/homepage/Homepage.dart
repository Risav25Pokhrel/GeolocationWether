import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocationweather/homepage/searchedlocation.dart';
import 'package:geolocationweather/onboarding/helper.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Location location = Location();
late bool _serviceEnabled;
late PermissionStatus _permissionGranted;
late LocationData _locationData;

Future<dynamic> geolocation() async {
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  _locationData = await location.getLocation();
  return _locationData;
}

// ignore: prefer_typing_uninitialized_variables

Future<Map?> fetchWeather() async {
  await geolocation();
  final response = await http.get(Uri.parse(
      "http://api.weatherapi.com/v1/current.json?key=1bc0383d81444b58b1432929200711&q=${_locationData.latitude},${_locationData.longitude}"));
  print(
      "http://api.weatherapi.com/v1/current.json?key=1bc0383d81444b58b1432929200711&q=${_locationData.latitude},${_locationData.longitude}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body.toString());
  } else {
    return null;
  }
}

final iconState = StateProvider<bool>((ref) => true);
final futureProvider = FutureProvider<Map?>((ref) => fetchWeather());
final enteredlocation = TextEditingController();

// ignore: must_be_immutable
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late List<String> searchedhistory;
  getsearchedlist() async {
    final open = await SharedPreferences.getInstance();
    searchedhistory = open.getStringList("searchedlist") ?? [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    enteredlocation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
          onPressed: () {
            setState(() {});
          },
          icon: const Icon(Icons.refresh)),
      resizeToAvoidBottomInset: true,
      body: NestedScrollView(
          headerSliverBuilder: ((context, innerBoxIsScrolled) => [
                SliverAppBar(
                  actions: [
                    TextButton.icon(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const onboarding())),
                        icon: const Icon(Icons.help),
                        label: const Text("HELP"))
                  ],
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  snap: true,
                  floating: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      onSubmitted: (value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => locationweather(
                                    place: enteredlocation.text.toString(),
                                    search: searchedhistory,
                                  )))),
                      controller: enteredlocation,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        hintStyle: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w300),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fillColor: Colors.white,
                        prefixIcon: enteredlocation.text.isEmpty
                            ? const Icon(Icons.search)
                            : null,
                        suffixIcon: IconButton(
                            onPressed: () {
                              enteredlocation.clear();
                            },
                            icon: const Icon(Icons.cancel_outlined)),
                        hintText: "ENTER LOCATION",
                      ),
                    ),
                  ),
                )
              ]),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Consumer(builder: ((context, ref, child) {
                  final futureCurrentWeather = ref.watch(futureProvider);
                  return futureCurrentWeather.when(
                    error: ((error, stackTrace) => const Center(
                          child: Text("AN ERROR OCCUR"),
                        )),
                    loading: (() => const Center(
                          child: CircularProgressIndicator(),
                        )),
                    data: ((data) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.97,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "COUNTRY: ${data?["location"]["country"]}",
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      "Last updated at: ${data?["current"]["last_updated"]}",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.red),
                                    ),
                                  ],
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Text(
                                  data?["location"]["name"],
                                  style: const TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  "${data?["current"]['temp_c']} °C (${data?["current"]['temp_f']} °F)",
                                  style: const TextStyle(fontSize: 35),
                                ),
                                const Spacer(),
                                Text(
                                  data?["current"]["condition"]["text"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        )),
                  );
                })),
                const SizedBox(
                  height: 60,
                ),
                Column(
                  children: [
                    const Text(
                      "Searched Country:-",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder(
                        future: getsearchedlist(),
                        builder: ((context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(
                                child: CircularProgressIndicator(),
                              );

                            default:
                              if (snapshot.hasError) {
                                return const Center();
                              } else {
                                return Container(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: searchedhistory.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  locationweather(
                                                    place:
                                                        searchedhistory[index],
                                                    search: searchedhistory,
                                                  )))),
                                      child: Card(
                                        child: Center(
                                            child: Text(
                                          searchedhistory[index],
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ),
                                    ),
                                  ),
                                );
                                //  Column(
                                //   children: [
                                //     const Text("SEARCHED HISTORY:-"),
                                //     ListView.builder(
                                //         scrollDirection: Axis.horizontal,
                                //         itemCount: searchedhistory.length,
                                //         itemBuilder: ((context, index) {
                                //           return GestureDetector(
                                //             child: Card(
                                //               elevation: 10,
                                //               child: Text(searchedhistory[index]),
                                //             ),
                                //           );
                                //         })),
                                //   ],
                                // );
                              }
                          }
                        })),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
