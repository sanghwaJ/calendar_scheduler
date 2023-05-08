import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// 상태 관리는 home_screen에서 하기 때문에 StatelessWidget으로 선언
class Calendar extends StatelessWidget {
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final OnDaySelected? onDaySelected;

  const Calendar({
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBoxDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
      color: Colors.grey[200],
    );
    final defaultTextStyle = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.w700,
    );

    return TableCalendar(
      locale: 'ko_KR', // 다국어 처리
      // 보여지는 기준 날짜
      focusedDay: focusedDay, // widget. => statefulWidget의 변수를 받아올 수 있음
      // 달력의 가장 첫 번째 날짜
      firstDay: DateTime(1800),
      // 달력의 가장 마지막 날짜
      lastDay: DateTime(3000),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
        ),
      ),
      calendarStyle: CalendarStyle(
        // 오늘 날짜 Highlighted
        isTodayHighlighted: false,
        // 날짜 컨테이너들의 Decoration
        defaultDecoration: defaultBoxDeco,
        // 주말 날짜 컨테이너들의 Decoration
        weekendDecoration: defaultBoxDeco,
        selectedDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          // 상하좌우 테두리 동일한 설정
          border: Border.all(
            color: PRIMARY_COLOR,
            width: 1.0,
          ),
        ),
        outsideDecoration: BoxDecoration(
          // border 설정이 적용되도록 outsideDecoration을 circle => rectangle 변경
          shape: BoxShape.rectangle,
        ),
        defaultTextStyle: defaultTextStyle,
        weekendTextStyle: defaultTextStyle,
        selectedTextStyle: defaultTextStyle.copyWith(
          color: PRIMARY_COLOR,
        ),
      ),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (DateTime date) {
        // 빌드가 재실행될 때마다 아래의 코드 실행
        if (selectedDay == null) {
          return false;
        }

        // selectedDay의 year, month, day가 모두 같으면 선택된 날짜로 인식
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
      },
    );
  }
}
