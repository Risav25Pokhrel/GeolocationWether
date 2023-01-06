import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class locationweather extends StatefulWidget {
  const locationweather({super.key, required this.place, required this.search});
  final String place;
  final List<String> search;
  @override
  State<locationweather> createState() => _locationweatherState();
}

class _locationweatherState extends State<locationweather> {
  var data;

  

  getweather(String place) async {
    final response = await http.get(Uri.parse(
        "http://api.weatherapi.com/v1/current.json?key=1bc0383d81444b58b1432929200711&q=${place.toLowerCase()}"));

    if (response.statusCode == 200) {
      data = jsonDecode(response.body.toString());
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.place.toUpperCase()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FutureBuilder(
              future: getweather(widget.place),
              builder: ((context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());

                  default:
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("SORRY! THE LOCATION IS NOT FOUND"),
                      );
                    } else {
                      return Container(
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
                      );
                    }
                }
              })),
          ElevatedButton(
              onPressed: () async {
                if (widget.search.contains(data?["location"]["name"])) {
                  final snackbar = SnackBar(
                      content: Text(
                          "${data?["location"]["name"]} updated successfully"));
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                } else {
                 widget.search.add(data?["location"]["name"]);
                  final save = await SharedPreferences.getInstance();
                  save.setStringList("searchedlist",widget.search);
                  setState(() {});
                  final snackbar = SnackBar(
                      content: Text(
                          "${data?["location"]["name"]} added successfully"));
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                }
              },
              child:widget. search.contains(data?["location"]["name"])
                  ? const Text("UPDATE this location")
                  : const Text("Save this location"))
        ],
      ),
    );
  }
}
