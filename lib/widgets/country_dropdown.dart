import 'package:flutter/material.dart';
import 'package:weather_app/models/countries.dart';

class CountryDropdownField extends StatelessWidget {
  final Function onChanged;
  final Country? country;

  const CountryDropdownField({
    Key? key,
    required this.onChanged,
    this.country,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<Country>(
        items: Country.ALL.map((Country country) {
          return DropdownMenuItem(
            child: Text(country.name),
            value: country,
          );
        }).toList(),
        value: country ?? Country.AD,
        onChanged: (Country? newSelection) => onChanged(newSelection),
        isExpanded: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Country',
        ),
      ),
    );
  }
}
