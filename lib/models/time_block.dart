class TimeBlock {
  TimeBlock({required this.time, required this.isOn});

  static TimeBlock zero =
      TimeBlock(time: DateTime(0, 0, 0, 0, 0, 0, 0, 0), isOn: false);

  bool isOn;

  DateTime time;

  set setTime(DateTime newTime) => time = newTime;

  set setIsOn(bool newIsOn) => isOn = newIsOn;
}
