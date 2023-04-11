import 'package:admob_flutter/admob_flutter.dart';
import 'package:dust/data/api.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import 'data/mise.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
// Initialize without device test ids.
  Admob.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Color> colors = [
    Color(0xFF0077c2),
    Color(0xFF009ba9),
    Color(0xfffe6300),
    Color(0xFFd80019),
  ];
  List<String> icon = [
    "assets/img/happy.png",
    "assets/img/sceptic.png",
    "assets/img/sad.png",
    "assets/img/angry.png"
  ];
  List<String> status = ["좋음", "보통", "나쁨", "최악"];
  String stationName = "서초구";
  List<Mise> data = [];

  int getStatus(Mise mise) {
    if (mise.pm10 > 150) {
      return 3;
    } else if (mise.pm10 > 80) {
      return 2;
    } else if (mise.pm10 > 30) {
      return 1;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    getMiseData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String l = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => LocationPage()));
          if (l != null) {
            stationName = l;
            getMiseData();
          }
          InAppReview.instance.requestReview();
        },
        tooltip: "Increment",
        child: Icon(Icons.location_on),
      ),
    );
  }

  Widget getPage() {
    if (data.isEmpty) {
      return Container();
    }

    int _status = getStatus(data.first);
    return Container(
      color: colors[_status],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 60),
          Text(
            "현재 위치",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 12),
          Text("[$stationName]",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white)),
          SizedBox(height: 60),
          Image.asset(
            icon[_status],
            fit: BoxFit.contain,
            width: 220,
            height: 220,
          ),
          SizedBox(height: 60),
          Text(status[_status],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text("통합 환경 대기 지수 : ${data.first.khai}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white)),
          Expanded(
            child: Container(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(data.length, (idx) {
                  Mise mise = data[idx];
                  int _status = getStatus(mise);

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          mise.dataTime.replaceAll(" ", "\n"),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Container(
                          child:
                              Image.asset(icon[_status], fit: BoxFit.contain),
                          height: 40,
                          width: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${mise.pm10}ug/m2",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          AdmobBanner(
            adUnitId: AdmobBanner.testAdUnitId,
            adSize: AdmobBannerSize.BANNER,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  void getMiseData() async {
    MiseApi api = MiseApi();
    data = await api.getMiseDate(stationName);
    data.removeWhere((m) => m.pm10 == 0);
    setState(() {});
  }
}

class LocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationPage();
  }
}

class _LocationPage extends State<LocationPage> {
  List<String> locations = ["구로구", "동작구", "마포구", "강남구", "강동구"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: List.generate(locations.length, (idx) {
          return ListTile(
            title: Text(locations[idx]),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).pop(locations[idx]);
            },
          );
        }),
      ),
    );
  }
}
