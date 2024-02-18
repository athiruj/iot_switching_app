import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iot_switch/models/switch_btn.dart';

class SlidableTimeListItem extends StatelessWidget {
  const SlidableTimeListItem({
    required this.provider,
    required this.index,
    super.key,
  });

  final SwitchProvider provider;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    Color getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return color.primary;
      }
      return color.secondary;
    }

    return Slidable(
      endActionPane: ActionPane(motion: const BehindMotion(), children: [
        SlidableAction(
          onPressed: (context) => provider.removeTimeHistory(index),
          backgroundColor: color.error,
          icon: Icons.delete,
          label: 'delete',
        ),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                SizedBox(
                  width: 40.0,
                  child: Center(
                    child: Text(
                      '${(provider.timeHistory[index].time.hour < 10) ? '0' : ''}${provider.timeHistory[index].time.hour}',
                      style: const TextStyle(
                        color: Color(0xFF4D4D4D),
                        fontWeight: FontWeight.w600,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    color: Color(0xFF4D4D4D),
                    fontWeight: FontWeight.w600,
                    fontSize: 24.0,
                  ),
                ),
                SizedBox(
                  width: 40.0,
                  child: Center(
                    child: Text(
                      '${(provider.timeHistory[index].time.minute < 10) ? '0' : ''}${provider.timeHistory[index].time.minute}',
                      style: const TextStyle(
                        color: Color(0xFF4D4D4D),
                        fontWeight: FontWeight.w600,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.timeHistory[index].isOn,
            inactiveThumbColor: color.secondary,
            trackOutlineColor: MaterialStateProperty.resolveWith(
                ((states) => getColor(states))),
            onChanged: (bool value) {
              provider.changeIsOn(index, value);
            },
          ),
        ],
      ),
    );
  }
}
