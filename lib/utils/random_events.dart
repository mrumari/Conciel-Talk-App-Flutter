import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:intl/intl.dart';

class RandomDateTime extends StatelessWidget {
  const RandomDateTime({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final lastDayOfNextWeek = now.add(const Duration(days: 14));
    final randomDay = nextWeek.add(
      Duration(
        days: random.nextInt(lastDayOfNextWeek.difference(nextWeek).inDays),
      ),
    );
    final randomHour = 6 + random.nextInt(18);
    final randomMinute = random.nextBool() ? 0 : 30;
    final randomDateTime = DateTime(
      randomDay.year,
      randomDay.month,
      randomDay.day,
      randomHour,
      randomMinute,
    );

    return Text(randomDateTime.toString());
  }
}

class RandomDateTimeList extends StatelessWidget {
  final int events;

  const RandomDateTimeList({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final randomDateTimes = List.generate(
      events,
      (index) => const RandomDateTime().build(context) as Text,
    );
    final groupedDateTimes =
        groupBy(randomDateTimes, (Text element) => element.data!.split(' ')[0]);

    final sortedGroupedDateTimes =
        SplayTreeMap<DateTime, List<Text>>.fromIterable(
      groupedDateTimes.entries,
      key: (entry) => DateTime.parse(entry.key),
      value: (entry) => entry.value,
    );

    return Column(
      children: sortedGroupedDateTimes.entries.map((entry) {
        final date = entry.key;
        final formattedDate =
            DateFormat('d MMMM yyyy').format(date).toUpperCase();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate),
            Text(
              'EVENTS (${entry.value.length})',
              style: const TextStyle(color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            ...entry.value.map(
              (text) {
                final dateTime = DateTime.parse(text.data!);
                final formattedTime = DateFormat('HH:mm').format(dateTime);
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    formattedTime,
                    style: TextStyle(color: personalColorScheme.outline),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
