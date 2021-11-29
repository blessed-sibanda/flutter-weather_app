import 'package:flutter/material.dart';
import 'package:weather_app/models/app_settings.dart';
import 'package:weather_app/pages/page_container.dart';
import 'package:weather_app/styles.dart';

void main() {
  AppSettings settings = AppSettings();

  runApp(
    MyApp(settings: settings),
  );
}

class MyApp extends StatelessWidget {
  final AppSettings settings;

  const MyApp({Key? key, required this.settings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      fontFamily: 'Cabin',
      primaryColor: AppColor.midnightSky,
      secondaryHeaderColor: AppColor.midnightCloud,
      primaryTextTheme: Theme.of(context).textTheme.apply(
            bodyColor: AppColor.textColorDark,
            displayColor: AppColor.textColorDark,
          ),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: AppColor.textColorDark,
            displayColor: AppColor.textColorDark,
          ),
    );
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: PageContainer(settings: settings),
    );
  }
}
