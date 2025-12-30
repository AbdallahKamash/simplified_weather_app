import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String mainFont = 'sg';

ScrollController todayListCon = ScrollController();

const List<String> citys = [
  'Tripoli',
  'Benghazi',
  'Khoms',
  'Tobruk',
  'Misratah',
  'Sabha',
  'Susah, Libya',
  'Al Zawiyah',
  'Shahat',
  'Ajdabiyah',
  'Zliten',
  'Zintan',
  'Janzur, Libya',
  'Ubari',
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Home(), debugShowCheckedModeBanner: false));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String cityName = 'Benghazi';
  bool isDay = true;
  Future<Map<String, dynamic>>? weatherFuture;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cityName = prefs.getString('cityName') ?? 'Benghazi';
      weatherFuture = getData(cityName);
    });
  }

  Future<Map<String, dynamic>> getData(String city) async {
    final params = {
      'days': '5',
      'key': 'bfb2575c069e46b9ac9102725240209',
      'q': city,
      'aqi': 'yes',
    };

    final uri = Uri.https('api.weatherapi.com', '/v1/forecast.json', params);
    var res = await http.get(uri);
    return jsonDecode(res.body);
  }

  void _updateTheme(BuildContext context) {
    // If system is dark mode, force night theme (isDay = false)
    // Otherwise, use time of day
    final brightness = MediaQuery.of(context).platformBrightness;
    bool systemDark = brightness == Brightness.dark;

    if (systemDark) {
      isDay = false;
    } else {
      // Logic: Night if hour >= 19
      int currentHour = int.parse(DateFormat('H').format(DateTime.now()));
      if (currentHour >= 19) {
        isDay = false;
      } else {
        isDay = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateTheme(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: weatherFuture,
      builder: (context, snapshot) {
        double dw = MediaQuery.of(context).size.width;
        double dh = MediaQuery.of(context).size.height;

        // Default empty container if no data/loading/error for now based on original code style
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData ||
            snapshot.hasError) {
          return Scaffold(
            backgroundColor: isDay ? Colors.white : Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: isDay ? const Color(0xff302745) : Colors.white,
              ),
            ),
          );
        }

        var data = snapshot.data!;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                height: dh,
                width: dw,
                color: isDay ? Colors.white : Colors.black,
              ),
              Stack(
                children: [
                  Positioned(
                    left: isDay ? 100 : -180,
                    top: isDay ? 186 : 44,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                      child: Align(
                        child: SizedBox(
                          width: 480,
                          height: 480,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(240),
                              gradient: RadialGradient(
                                center: const Alignment(-0, -0.746),
                                radius: 0.95,
                                colors: isDay
                                    ? [
                                        const Color(0x99eb20d7),
                                        const Color(0x99eb5c20),
                                        const Color(0x99ffd645),
                                        const Color(0x99090315),
                                      ]
                                    : [
                                        const Color(0x803B185F),
                                        const Color(0x80C060A1),
                                        const Color(0x8000005C),
                                        const Color(0x00090315),
                                      ],
                                stops: const [0, 0.286, 0.635, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: dw,
                height: dh,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ScrollConfiguration(
                  behavior: NoGlowListView(),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header Row
                        SizedBox(height: 40), // Top spacing
                        Container(
                          width: dw,
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            20,
                            20,
                            0,
                          ), // Added right padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                // Use expanded to prevent overflow
                                child: InkWell(
                                  onTap: () {
                                    _showSimpleDialog();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${data['location']['name']}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: mainFont,
                                          color: isDay
                                              ? const Color(0xff302745)
                                              : Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        ' ${data['location']['country']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: mainFont,
                                          color: isDay
                                              ? const Color(0xcc302745)
                                              : Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                        // Main Temp Display
                        Container(
                          width: dw,
                          // Removed fixed conditional height, let it be responsive padding
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: dw / 3, // slightly larger
                                height: dw / 3,
                                color: Colors.transparent,
                                child: weatherIcon(
                                  (data['current']['condition']['text'])
                                      .toString(),
                                  isDay,
                                ),
                              ),
                              Center(
                                child: Text(
                                  ' ${data['current']['temp_c']}°',
                                  style: TextStyle(
                                    fontFamily: mainFont,
                                    fontWeight: FontWeight.w400,
                                    fontSize: dw / 4,
                                    color: isDay
                                        ? const Color(0xff302745)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${data['current']['condition']['text']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: mainFont,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    color: isDay
                                        ? const Color(0xff302745)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                        // Stats Row
                        Container(
                          width: dw,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildStatItem(
                                    'Humidity',
                                    '${data['current']['humidity']} %',
                                    isDay,
                                  ),
                                  _buildStatItem(
                                    'Wind',
                                    '${data['current']['wind_kph']} km/h',
                                    isDay,
                                  ),
                                  _buildStatItem(
                                    'Visibility',
                                    '${data['current']['vis_km']} km',
                                    isDay,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  
                        Container(
                          margin: const EdgeInsets.all(15),
                          width: dw,
                          height: 3,
                          color: isDay ? const Color(0x33302745) : Colors.white,
                        ),
                  
                        // Hourly Forecast
                        Container(
                          width: dw,
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontFamily: mainFont,
                                        color: isDay
                                            ? const Color(0xff302745)
                                            : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${DateFormat('EE').format(DateTime.now())}, ${DateFormat('dd LLL').format(DateTime.now())}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: mainFont,
                                        color: isDay
                                            ? const Color(0xff302745)
                                            : Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: dw,
                                height: 110,
                                child: ScrollConfiguration(
                                  behavior: NoGlowListView(),
                                  child: ListView.builder(
                                    controller: todayListCon,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 24,
                                    itemBuilder: (context, index) {
                                      int j = index;
                                      int currentHour = int.parse(
                                        DateFormat('H').format(DateTime.now()),
                                      );
                  
                                      if (currentHour > j)
                                        return Container(); // Skip past hours ?? Original logic seems to just filter them out.
                                      // Actually original logic was: for loop 0..23, if currentHour <= j
                  
                                      // Correct logic: we ONLY want future hours.
                                      // Let's rely on the if check
                                      if (j < currentHour)
                                        return const SizedBox.shrink();
                  
                                      return SizedBox(
                                        width: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                currentHour == j
                                                    ? 'Now '
                                                    : '$j:00',
                                                style: TextStyle(
                                                  fontFamily: mainFont,
                                                  fontSize: 18,
                                                  color: isDay
                                                      ? const Color(0xcc302745)
                                                      : Colors.white,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              height: 30,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              child: weatherIcon(
                                                data['forecast']['forecastday'][0]['hour'][j]['condition']['text']
                                                    .toString(),
                                                isDay,
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                ' ${data['forecast']['forecastday'][0]['hour'][j]['temp_c']}°',
                                                style: TextStyle(
                                                  fontFamily: mainFont,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 22,
                                                  color: isDay
                                                      ? const Color(0xff302745)
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                        Container(
                          margin: const EdgeInsets.all(15),
                          width: dw,
                          height: 3,
                          color: isDay ? const Color(0x33302745) : Colors.white,
                        ),
                  
                        // 3-Day Forecast
                        Container(
                          width: dw,
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '3-day forecast',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontFamily: mainFont,
                                        color: isDay
                                            ? const Color(0xff302745)
                                            : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Using standard Row with Expanded children for better spacing
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround, // Distribute evenly
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < 3; i++)
                                      _buildForecastDayItem(i, data, isDay),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, bool isDay) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: mainFont,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: isDay ? const Color(0xcc302745) : Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: mainFont,
              fontWeight: FontWeight.w500,
              fontSize: 22, // Slightly reduced to prevent overflow
              color: isDay ? const Color(0xff302745) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastDayItem(int i, Map<String, dynamic> data, bool isDay) {
    var dayData = data['forecast']['forecastday'][i];
    var date = DateTime.now().add(Duration(days: i));
    String dayString;

    if (i == 0) {
      dayString = 'Today';
    } else {
      String m = DateFormat('MM').format(date);
      String d = DateFormat('d').format(date);
      if (d.length == 1) d = '0$d';
      dayString = '$m/$d';
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dayString,
            style: TextStyle(
              fontFamily: mainFont,
              fontSize: 18,
              color: isDay ? const Color(0xcc302745) : Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            ' ${dayData['day']['maxtemp_c']}°',
            style: TextStyle(
              fontFamily: mainFont,
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: isDay ? const Color(0xff302745) : Colors.white,
            ),
          ),
          Text(
            ' ${dayData['day']['mintemp_c']}°',
            style: TextStyle(
              fontFamily: mainFont,
              fontWeight: FontWeight.w300,
              fontSize: 16,
              color: isDay ? const Color(0xff302745) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSimpleDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ScrollConfiguration(
          behavior: NoGlowListView(),
          child: SimpleDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            backgroundColor: const Color(0xff302745),
            title: const SizedBox(
              height: 40,
              child: Text(
                'Choose a city',
                style: TextStyle(color: Colors.white),
              ),
            ),
            children: <Widget>[
              for (int i = 0; i < citys.length; i++)
                SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      cityName = citys[i];
                      weatherFuture = getData(cityName);
                    });
                    prefs.setString('cityName', cityName);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    citys[i],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Image weatherIcon(String condition, bool isDay) {
  String asset;
  if (condition == 'Sunny') {
    asset = isDay ? 'assets/sunny.png' : 'assets/sunny_w.png';
  } else if (condition == 'rain') {
    asset = isDay ? 'assets/rainy.png' : 'assets/rainy_w.png';
  } else if (condition == 'Cloudy') {
    asset = isDay ? 'assets/cloudy.png' : 'assets/cloudy_w.png';
  } else if (condition == 'Clear') {
    asset = isDay ? 'assets/clear.png' : 'assets/clear_w.png';
  } else if (condition == 'Partly cloudy') {
    asset = isDay ? 'assets/partly_1.png' : 'assets/partly_2_w.png';
  } else {
    asset = isDay ? 'assets/cloudy.png' : 'assets/cloudy_w.png';
  }
  return Image.asset(asset);
}

class NoGlowListView extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
