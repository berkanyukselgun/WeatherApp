import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/search_page.dart';
import 'package:hava_durumu/widgets/Loading_widget.dart';
import 'package:hava_durumu/widgets/daily_weather.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = 'İstanbul';
  double? temperature;
  final String key = '471c2a6ae95fc5dba80d1974c88ca86b';
  var locationData;
  String code = 'Home';
  Position? devicePosition;
  String? icon;

  List<String> icons = [];
  List<double> temperatures = [];
  List<String> dates = [];

  void getInitialData() async {
    await getDevicePosition();
    await getLocationFromAPIByLatLon();
    await getDailyForecastByLatLon();
  }

  @override
  void initState() {
    getInitialData();
    // getLocationFromAPI();
    super.initState();
  }

  Future<void> getLocationFromAPI() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temperature = locationDataParsed['main']["temp"];
      location = locationDataParsed["name"];
      code = locationDataParsed['weather'].first['main'];
      icon = locationDataParsed['weather'].first['icon'];
    });
  }

  Future<void> getDevicePosition() async {
    devicePosition = await _determinePosition();
  }

  Future<void> getLocationFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
      final locationDataParsed = jsonDecode(locationData.body);

      setState(() {
        temperature = locationDataParsed['main']["temp"];
        location = locationDataParsed["name"];
        code = locationDataParsed['weather'].first['main'];
        icon = locationDataParsed['weather'].first['icon'];
      });
    }
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();
    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  Future<void> getDailyForecastByLocation() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();
    setState(() {
      temperatures.add(forecastDataParsed['list'][7]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][15]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][23]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][31]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][39]['main']['temp']);

      icons.add(forecastDataParsed['list'][7]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][15]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][23]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][31]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][39]['weather'][0]['icon']);

      dates.add(forecastDataParsed['list'][7]['dt_txt']);
      dates.add(forecastDataParsed['list'][15]['dt_txt']);
      dates.add(forecastDataParsed['list'][23]['dt_txt']);
      dates.add(forecastDataParsed['list'][31]['dt_txt']);
      dates.add(forecastDataParsed['list'][39]['dt_txt']);
    });
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration containerDecoration = BoxDecoration(
      image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage(
          'assets/$code.jpg',
        ),
      ),
    );
    return Container(
      decoration: containerDecoration,
      child: (temperature == null ||
              devicePosition == null ||
              icons.isEmpty ||
              dates.isEmpty ||
              temperatures.isEmpty)
          ? LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Image.network(
                          'https://openweathermap.org/img/wn/$icon@4x.png'),
                    ),
                    Text(
                      '$temperature° C',
                      style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 5,
                                offset: Offset(-3, 3))
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: const TextStyle(
                              fontSize: 40,
                              shadows: <Shadow>[
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 5,
                                    offset: Offset(-3, 3))
                              ]),
                        ),
                        IconButton(
                            onPressed: () async {
                              final selectedCity = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Search_Page()));
                              location = selectedCity;
                              getLocationFromAPI();
                              getDailyForecastByLocation();
                            },
                            icon: const Icon(Icons.search))
                      ],
                    ),
                    buildWeatherCard(context)
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildWeatherCard(BuildContext context) {
    List<DailyWeatherCard> cards = [];
    // DailyWeatherCard(
    //     icon: icons[0], temperature: temperatures[0], date: dates[0]),
    // DailyWeatherCard(
    //     icon: icons[1], temperature: temperatures[1], date: dates[1]),
    // DailyWeatherCard(
    //     icon: icons[2], temperature: temperatures[2], date: dates[2]),
    // DailyWeatherCard(
    //     icon: icons[3], temperature: temperatures[3], date: dates[3]),
    // DailyWeatherCard(
    //     icon: icons[4], temperature: temperatures[4], date: dates[4])

    for (int i = 0; i < 5; i++) {
      cards.add(DailyWeatherCard(
          icon: icons[i], temperature: temperatures[i], date: dates[i]));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
