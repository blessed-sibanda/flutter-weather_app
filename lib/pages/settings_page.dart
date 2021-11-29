import 'package:flutter/material.dart';
import 'package:weather_app/models/app_settings.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/pages/add_city_page.dart';
import 'package:weather_app/styles.dart';
import 'package:weather_app/utils/humanize.dart';
import 'package:weather_app/widgets/segmented_control.dart';

class SettingsPage extends StatefulWidget {
  final AppSettings settings;

  const SettingsPage({Key? key, required this.settings}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> get temperatureOptions =>
      Humanize.enumValues(TemperatureUnit.values);

  void _handleCityActiveChange(bool b, City city) {
    setState(() => city.active = b);
  }

  void _handleTemperatureUnitChange(int selection) {
    setState(() => widget.settings.selectedTemperatureUnit =
        TemperatureUnit.values.toList()[selection]);
  }

  void _handleDismiss(DismissDirection dir, City removedCity) {
    if (dir == DismissDirection.endToStart) {
      allAddedCities.removeWhere((city) => city == removedCity);
      if (widget.settings.activeCity == removedCity) {
        widget.settings.activeCity =
            allAddedCities.firstWhere((city) => city.active!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings Page',
          style: TextStyle(
            color: AppColor.textColorLight,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Temperature Unit'),
            SegmentedControl(
              temperatureOptions,
              onSelectionChanged: (int selection) =>
                  _handleTemperatureUnitChange(selection),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add new city'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return AddNewCityPage(settings: widget.settings);
                    },
                  ),
                );
              },
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allAddedCities.length,
                itemBuilder: (BuildContext context, int index) {
                  final city = allAddedCities[index];
                  return Dismissible(
                    key: ValueKey(city),
                    child: CheckboxListTile(
                      onChanged: (bool? b) => _handleCityActiveChange(b!, city),
                      title: Text(city.name!),
                      value: city.active,
                    ),
                    background: Container(
                      child: const Icon(Icons.delete_forever),
                      decoration: BoxDecoration(color: Colors.red[700]),
                    ),
                    onDismissed: (DismissDirection dir) =>
                        _handleDismiss(dir, city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
