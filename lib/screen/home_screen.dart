import 'package:calendar_scheduler/component/schedule_bottom_sheet.dart';
import 'package:calendar_scheduler/component/schedule_card.dart';
import 'package:calendar_scheduler/component/today_banner.dart';
import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';

import '../component/calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: renderFloatingActionButton(),
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
            ),
            SizedBox(
              height: 8.0,
            ),
            TodayBanner(
              selectedDay: selectedDay,
              scheduleCount: 3,
            ),
            SizedBox(
              height: 8.0,
            ),
            _ScheduleList(),
          ],
        ),
      ),
    );
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // 빌드 재실행, 빌드가 재실행될 때마다 selectedDay, focusedDay 업데이트
      this.selectedDay = selectedDay;
      // focusedDay를 selectedDay로 업데이트하여 달력 시점 이동
      this.focusedDay = selectedDay;
    });
  }

  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // showModalBottomSheet의 default height 값은 화면 크기의 절반
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // isScrollControlled: true => default height 값을 늘려줌
          builder: (_) {
            return ScheduleBottomSheet();
          },
        );
      },
      backgroundColor: PRIMARY_COLOR,
      child: Icon(
        Icons.add,
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  const _ScheduleList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        // ListView => Item들을 List로 표현
        // ListView의 장점 => 모든 갯수의 item을 미리 렌더링하지 않고, 스크롤을 내릴 때마다 필요한 Item을 렌더링하기 때문에 메모리 사용에 이점이 있음
        child: ListView.separated(
          itemCount: 100,
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 8.0,
            );
          },
          itemBuilder: (context, index) {
            return ScheduleCard(
              startTime: 8,
              endTime: 11,
              content: 'content $index',
              color: Colors.red,
            );
          },
        ),
      ),
    );
  }
}
