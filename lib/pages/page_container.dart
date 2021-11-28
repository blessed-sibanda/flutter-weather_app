// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:weather_app/models/app_settings.dart';
import 'package:weather_app/pages/forecast_page.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/utils/forecast_animation_utils.dart';
import 'package:weather_app/styles.dart';

class PageContainer extends StatefulWidget {
  final AppSettings settings;

  const PageContainer({Key? key, required this.settings}) : super(key: key);

  @override
  _PageContainerState createState() => _PageContainerState(settings);
}

class _PageContainerState extends State<PageContainer> {
  AppSettings settings;

  _PageContainerState(this.settings);

  void _showSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          settings: settings,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ForecastPage(
      menu: PopupMenuButton(
        elevation: 0.0,
        icon: const Icon(
          Icons.location_city,
          color: AppColor.textColorDark,
        ),
        onSelected: (selection) {
          setState(() {
            settings.activeCity =
                allAddedCities.firstWhere((city) => city.name == selection);
          });
        },
        itemBuilder: (BuildContext context) {
          return allAddedCities
              .where((city) => city.active)
              .map((city) =>
                  PopupMenuItem(child: Text(city.name), value: city.name))
              .toList();
        },
      ),
      settingsButton: TextButton(
        onPressed: _showSettingsPage,
        child: Text(
            AnimationUtil.temperatureLabels[settings.selectedTemperatureUnit]!,
            style: Theme.of(context).textTheme.headline1),
      ),
      settings: settings,
    );
  }
}
