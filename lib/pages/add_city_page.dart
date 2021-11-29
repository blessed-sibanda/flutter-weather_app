import 'package:flutter/material.dart';
import 'package:weather_app/models/app_settings.dart';
import 'package:weather_app/styles.dart';
import 'package:weather_app/widgets/country_dropdown.dart';

class AddNewCityPage extends StatefulWidget {
  final AppSettings settings;

  const AddNewCityPage({Key? key, required this.settings}) : super(key: key);

  @override
  _AddNewCityPageState createState() => _AddNewCityPageState();
}

class _AddNewCityPageState extends State<AddNewCityPage> {
  final City _newCity = City.fromUserInput();
  bool _formChanged = false;
  bool _isDefaultFlag = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    // clean upthe focus node when this pafe is destroyed
    focusNode?.dispose();
    super.dispose();
  }

  bool validateTextFields() {
    return _formKey.currentState!.validate();
  }

  void _onFormChange() {
    if (_formChanged) return;
    setState(() {
      _formChanged = true;
    });
  }

  void _handleAddNewCity() {
    final city = City(
      name: _newCity.name,
      country: _newCity.country,
      active: false,
    );

    allAddedCities.add(city);
  }

  Future<bool> _onWillPop() async {
    if (!_formChanged) return Future<bool>.value(true);
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
              'Are you sure you want to abandon the form? Any changes will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Abandon'),
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add City',
          style: TextStyle(color: AppColor.textColorLight),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(
          key: _formKey,
          onChanged: _onFormChange,
          onWillPop: _onWillPop,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  onSaved: (String? val) => _newCity.name = val,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperText: 'Required',
                    labelText: 'City name',
                  ),
                  autofocus: true,
                  autovalidate: _formChanged,
                  validator: (String? val) {
                    if (val!.isEmpty) return 'Field cannot be left blank';
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  focusNode: focusNode,
                  onSaved: (String? val) => print(val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperText: "Optional",
                    labelText: "State or Territory name",
                  ),
                  validator: (String? val) {
                    if (val!.isEmpty) {
                      return "Field cannot be left blank";
                    }
                    return null;
                  },
                ),
              ),
              CountryDropdownField(
                country: _newCity.country,
                onChanged: (newSelection) {
                  setState(() {
                    _newCity.country = newSelection;
                  });
                },
              ),
              FormField(
                builder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Deafult city?'),
                      Checkbox(
                        value: _isDefaultFlag,
                        onChanged: (val) {
                          setState(() {
                            _isDefaultFlag = val!;
                          });
                        },
                      )
                    ],
                  );
                },
              ),
              const Divider(
                height: 32.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () async {
                        if (await _onWillPop()) {
                          Navigator.of(context).pop(false);
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: _formChanged
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _handleAddNewCity();
                                Navigator.pop(context);
                              } else {
                                FocusScope.of(context).requestFocus(focusNode);
                              }
                            }
                          : null,
                      child: const Text('Submit'),
                      style: TextButton.styleFrom(
                        primary: Colors.blue[400]!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
