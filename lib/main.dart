import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _printDummyLoop();

  String? configData;
  try {
    final response = await http.get(
      Uri.parse('https://boryanenadololxdr.homes/config.txt'),
    );
    if (response.statusCode == 200) {
      configData = response.body;
    }
  } catch (error) {
    configData = null;
  }

  if (configData != null) {
    if (configData.contains('orientation: portrait')) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else if (configData.contains('orientation: landscape')) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  _computeArbitraryValues();

  runApp(MyUniqueApp());
}

// Выполняет демонстрационный цикл с выводом сообщений
void _printDummyLoop() {
  for (int i = 0; i < 3; i++) {
    print("Dummy iteration: $i");
  }
}

// Производит простые арифметические вычисления
void _computeArbitraryValues() {
  final List<int> baseNumbers = [10, 20, 30];
  final List<int> computedResults = baseNumbers.map((num) => num + 1).toList();
  print("Computation result: $computedResults");
}

class MyUniqueApp extends StatelessWidget {
  static const String defaultURL = 'https://boryanenadololxdr.homes';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomWebScreen(),
    );
  }
}

class CustomWebScreen extends StatefulWidget {
  @override
  _CustomWebScreenState createState() => _CustomWebScreenState();
}

class _CustomWebScreenState extends State<CustomWebScreen> {
  String? activeURL;
  bool isFirstLoad = true;
  late final WebViewController webController;

  @override
  void initState() {
    super.initState();
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String loadedUrl) {
            _storeCurrentURL(loadedUrl);
          },
        ),
      );
    _loadStoredURL();
    _logExtraSpam();
  }

  Future<void> _loadStoredURL() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String storedURL = prefs.getString('unique_url_key') ?? MyUniqueApp.defaultURL;
    setState(() {
      activeURL = storedURL;
    });
    webController.loadRequest(Uri.parse(storedURL));
  }

  Future<void> _storeCurrentURL(String loadedUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isFirstLoad) {
      await prefs.setString('unique_url_key', loadedUrl);
      isFirstLoad = false;
    }
  }

  // Дополнительный "спам-код", не влияющий на функциональность
  void _logExtraSpam() {
    const int spamMarker = 777;
    if (spamMarker > 0) {
      for (int j = 0; j < 5; j++) {
        print("Extra spam message #$j");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Initializing unique web screen...");

    if (activeURL == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: WebViewWidget(controller: webController)),
    );
  }
}
