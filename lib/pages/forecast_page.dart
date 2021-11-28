import 'package:flutter/material.dart';
import 'package:weather_app/controllers/forecast_controller.dart';
import 'package:weather_app/models/app_settings.dart';
import 'package:weather_app/models/forecast_animation_state.dart';
import 'package:weather_app/models/offset_sequence_animation.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/utils/forecast_animation_utils.dart';
import 'package:weather_app/utils/humanize.dart';
import 'package:weather_app/utils/flutter_ui_utils.dart' as ui;
import 'package:weather_app/widgets/clouds_background.dart';
import 'package:weather_app/widgets/color_transition_box.dart';
import 'package:weather_app/widgets/color_transition_text.dart';
import 'package:weather_app/widgets/forecast_table.dart';
import 'package:weather_app/widgets/sun_background.dart';
import 'package:weather_app/widgets/time_picker_row.dart';
import 'package:weather_app/widgets/transition_appbar.dart';

class ForecastPage extends StatefulWidget {
  final PopupMenuButton menu;
  final Widget settingsButton;
  final AppSettings settings;

  const ForecastPage({
    Key? key,
    required this.menu,
    required this.settingsButton,
    required this.settings,
  }) : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage>
    with TickerProviderStateMixin {
  int activeTabIndex = 0;
  late ForecastController _forecastController;
  late AnimationController _animationController;
  late AnimationController _weatherConditionAnimationController;
  late ColorTween _colorTween;
  late ColorTween _backgroundColorTween;
  late ColorTween _textColorTween;
  late ColorTween _cloudColorTween;
  late Tween<Offset> _positionOffsetTween;
  late TweenSequence<Offset> _cloudPositionOffsetTween;
  late ForecastAnimationState currentAnimationState;
  late ForecastAnimationState nextAnimationState;
  late Offset verticalDragStart;

  @override
  void initState() {
    super.initState();
    _forecastController = ForecastController(widget.settings.activeCity);
    _render();
  }

  @override
  void didUpdateWidget(ForecastPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _render();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _weatherConditionAnimationController.dispose();
    super.dispose();
  }

  void _render() {
    _forecastController.city = widget.settings.activeCity;
    var startTime =
        _forecastController.selectedHourlyTemperature!.dateTime.hour;
    currentAnimationState = AnimationUtil.getDataForNextAnimationState(
      selectedDay: _forecastController.selectedDay!,
      currentlySelectedTimeOfDay: startTime,
    );
    final activeTabIndex = AnimationUtil.hours.indexOf(startTime);
    _handleStateChange(activeTabIndex);
  }

  void _handleStateChange(int activeIndex) {
    /// If choosing the same tab, there's nothing to animate.
    if (activeIndex == activeTabIndex) return;

    /// The next animation state represents the _end_ values
    /// for the next animation that fires. (It will also become the
    /// starting values for the _next_ animation cycle)
    nextAnimationState = AnimationUtil.getDataForNextAnimationState(
      selectedDay: _forecastController.selectedDay!,
      currentlySelectedTimeOfDay:
          _forecastController.selectedHourlyTemperature!.dateTime.hour,
    );

    /// These methods build all the relevant objects
    /// _and_ call `AnimationController.forward()`
    _buildAnimationController();
    _buildTweens();
    _initAnimation();

    /// At this point, multiple values on this object
    /// have been updated. Even though only `activeTabIndex` is
    /// set within the callback of setState, _all_ of the changed
    /// values on this object will be built appropriately.
    setState(() {
      activeTabIndex = activeIndex;
    });

    var nextSelectedHour = AnimationUtil.getSelectedHourFromTabIndex(
      activeIndex,
      _forecastController.selectedDay!,
    );

    /// set the selectedHourlyTemperature on the controller
    /// with the data from the _new_ values.
    /// This way, the data for the _next_ animation cycle
    /// is already loaded in.
    _forecastController.selectedHourlyTemperature =
        ForecastDay.getWeatherForHour(
      _forecastController.selectedDay!,
      nextSelectedHour,
    );
    currentAnimationState = nextAnimationState;
  }

  void _handleDragEnd(DragUpdateDetails d, BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var dragEnd = d.globalPosition.dy;
    var percentage = (dragEnd / screenHeight) * 100.0;
    var scaleToTimesOfDay = (percentage ~/ 12).toInt();
    if (scaleToTimesOfDay > 7) scaleToTimesOfDay = 7;
    _handleStateChange(scaleToTimesOfDay);
  }

  void _buildAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _weatherConditionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _buildTweens() {
    _colorTween = ColorTween(
      begin: currentAnimationState.sunColor,
      end: nextAnimationState.sunColor,
    );

    _backgroundColorTween = ColorTween(
      begin: currentAnimationState.backgroundColor,
      end: nextAnimationState.backgroundColor,
    );

    _textColorTween = ColorTween(
      begin: currentAnimationState.textColor,
      end: nextAnimationState.textColor,
    );

    _cloudColorTween = ColorTween(
      begin: currentAnimationState.cloudColor,
      end: nextAnimationState.cloudColor,
    );

    _positionOffsetTween = Tween<Offset>(
      begin: currentAnimationState.sunOffsetPosition,
      end: nextAnimationState.sunOffsetPosition,
    );

    var cloudOffsetSequence = OffsetSequence.fromBeginAndEndPositions(
      currentAnimationState.cloudOffsetPosition,
      nextAnimationState.cloudOffsetPosition,
    );

    _cloudPositionOffsetTween = TweenSequence(<TweenSequenceItem<Offset>>[
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: cloudOffsetSequence.positionA,
          end: cloudOffsetSequence.positionB,
        ),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: cloudOffsetSequence.positionB,
          end: cloudOffsetSequence.positionC,
        ),
        weight: 50.0,
      ),
    ]);
  }

  void _initAnimation() {
    _animationController.forward();
    _weatherConditionAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final _currentTemp = Humanize.currentTemperature(
      widget.settings.selectedTemperatureUnit,
      _forecastController.selectedHourlyTemperature!,
    );
    final _weatherDescription = Humanize.weatherDescription(
      _forecastController.selectedHourlyTemperature!,
    );
    final isRaining =
        _forecastController.selectedHourlyTemperature!.description ==
            WeatherDescription.rain;
    final forecastContent = ForecastTableView(
      textColorTween: _textColorTween,
      controller: _animationController,
      forecast: _forecastController.forecast!,
      settings: widget.settings,
    );
    final mainContent = Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          ColorTransitionText(
            text: _weatherDescription,
            style: Theme.of(context).textTheme.headline5!,
            animation: _textColorTween.animate(_animationController),
          ),
          ColorTransitionText(
            text: _currentTemp,
            style: Theme.of(context).textTheme.headline2!,
            animation: _textColorTween.animate(_animationController),
          ),
        ],
      ),
    );

    final timePickerRow = TimePickerRow(
      tabItems: Humanize.allHours(),
      forecastController: _forecastController,
      onTabChange: (int selectedTabIndex) =>
          _handleStateChange(selectedTabIndex),
      startIndex: activeTabIndex,
    );

    return Scaffold(
      appBar: PreferredSize(
        child: TransitionAppBar(
            title: ColorTransitionText(
              text: _forecastController.selectedHourlyTemperature!.city.name,
              style: Theme.of(context).textTheme.headline5!,
              animation: _textColorTween.animate(_animationController),
            ),
            actionIcon: widget.settingsButton,
            leadingAction: widget.menu,
            animation: _backgroundColorTween.animate(_animationController)),
        preferredSize: Size.fromHeight(ui.appBarHeight(context)),
      ),
      body: GestureDetector(
          onDoubleTap: () {
            setState(
              () {
                widget.settings.selectedTemperatureUnit ==
                        TemperatureUnit.celsius
                    ? widget.settings.selectedTemperatureUnit =
                        TemperatureUnit.fahrenheit
                    : widget.settings.selectedTemperatureUnit =
                        TemperatureUnit.celsius;
              },
            );
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            _handleDragEnd(details, context);
          },
          child: ColorTransitionBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Stack(
                children: [
                  SlideTransition(
                    position: _positionOffsetTween.animate(
                      _animationController.drive(
                        CurveTween(curve: Curves.bounceOut),
                      ),
                    ),
                    child: Sun(
                      animation: _colorTween.animate(_animationController),
                    ),
                  ),
                  SlideTransition(
                    position: _cloudPositionOffsetTween.animate(
                      _animationController.drive(
                        CurveTween(curve: Curves.bounceOut),
                      ),
                    ),
                    child: Clouds(
                      isRaining: isRaining,
                      animation: _cloudColorTween.animate(_animationController),
                    ),
                  ),
                  Column(
                    verticalDirection: VerticalDirection.up,
                    children: [
                      forecastContent,
                      mainContent,
                      Flexible(child: timePickerRow),
                    ],
                  ),
                ],
              ),
            ),
            animation: _backgroundColorTween.animate(_animationController),
          )),
    );
  }
}
