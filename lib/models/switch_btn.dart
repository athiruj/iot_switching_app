import 'package:flutter/material.dart';
import 'package:iot_switch/models/time_block.dart';

class SwitchProvider with ChangeNotifier {
  bool status = false;

  DateTime nextTime = DateTime(0, 0, 0, 0, 0, 0, 0, 0);

  final List<TimeBlock> timeHistory = [];

  void nextTimeAction() {
    nextTime = _nextTime();
    notifyListeners();
  }

  void statusSet(bool newStatus) {
    status = newStatus;
    notifyListeners();
  }

  void statusNextTime() {
    nextTime = _nextTime();
    notifyListeners();
  }

  void addTimeHistory(DateTime newTime, {bool newIsOn = true}) {
    timeHistory.add(TimeBlock(
        time: DateTime(0, 0, 0, newTime.hour, newTime.minute, 0, 0, 0),
        isOn: newIsOn));
    statusNextTime();
    notifyListeners();
  }

  void removeTimeHistory(int idx) {
    timeHistory.removeAt(idx);
    statusNextTime();
    notifyListeners();
  }

  void changeIsOn(int idx, bool newIsOn) {
    timeHistory[idx].isOn = newIsOn;
    statusNextTime();
    notifyListeners();
  }

  DateTime _nextTime() {
    int h = 1499;
    int m;
    List<TimeBlock> isOnElement =
        timeHistory.where((element) => element.isOn).toList();
    DateTime now = DateTime.now();
    DateTime useNow = DateTime(0, 0, 0, now.hour, now.minute, 0, 0, 0);
    DateTime newNextTime = DateTime(0, 0, 0, 0, 0, 0, 0, 0);

    if (isOnElement.length == 1) {
      return isOnElement[0].time;
    }

    for (var element in isOnElement) {
      if (element.time.isAfter(useNow)) {
        m = element.time.difference(useNow).inMinutes;
        if (h > m) {
          h = m;
          newNextTime = element.time;
        }
      }
    }

    if (newNextTime.isBefore(useNow)) {
      for (var i = 0; i < isOnElement.length - 1; i++) {
        TimeBlock element = isOnElement[i];
        if (element.time.isBefore(isOnElement[i + 1].time)) {
          newNextTime = element.time;
        } else {
          newNextTime = isOnElement[i + 1].time;
        }
      }
    }

    notifyListeners();
    return newNextTime;
  }
}
