import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/const/colors.dart';
import 'package:calendar_scheduler/database/drift_database.dart';
import 'package:calendar_scheduler/model/category_color.dart';
import 'package:drift/drift.dart'
    show Value; // drift 패키지에도 Column이 있기 때문에 Value만 가져오도록 함
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:calendar_scheduler/database/drift_database.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet({
    required this.selectedDate,
    this.scheduleId, // null일 수 있음
    Key? key,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  // 값을 저장하기 위해 관리하는 변수
  int? startTime;
  int? endTime;
  String? content;
  // database와 관련된 ID는 PK처럼 관리
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    // viewInsets => 전체 스크린 화면 중 System UI에 의해 가려진 크기 리턴
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        // 빈 화면 클릭 시, Focus out
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FutureBuilder<Schedule>(
          future: widget.scheduleId == null
              ? null
              : GetIt.I<LocalDatabase>().getScheduleById(widget.scheduleId!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('스케줄을 불러올 수 없습니다.'),
              );
            }

            // FutureBuilder가 처음 실행되고, 로딩중일때
            // ConnectionState.waiting을 조건으로 걸지않은 이유는 매번 로딩을 할 때마다 로딩 위젯을 보여주기 때문
            if (snapshot.connectionState != ConnectionState.none &&
                !snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Future가 실행이 되고 값이 있는데, 단 한 번도 startTime이 셋팅되지 않았을 때
            // 만일 조건을 snapshot.hasData만 주면, 매번 빌드가 될 때마다 계속 값이 리셋되어버림
            if (snapshot.hasData && startTime == null) {
              startTime = snapshot.data!.startTime;
              endTime = snapshot.data!.endTime;
              content = snapshot.data!.content;
              selectedColorId = snapshot.data!.colorId;
            }

            return SafeArea(
              child: Container(
                color: Colors.white,
                // keyboard Open되었을 때, 그 크기만큼 늘려줌
                height: MediaQuery.of(context).size.height / 2 + bottomInset,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 16.0,
                    ),
                    child: Form(
                      // key => FormController 역할, Form 아래에 있는 모든 TextFormField를 컨트롤 할 수 있음
                      key: formKey,
                      // validator 함수를 값이 변할 때마다 실행
                      // autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Time(
                            onStartSaved: (String? val) {
                              // validator에서 걸러주기 때문에 null일 수 없음 => !를 사용
                              startTime = int.parse(val!);
                            },
                            onEndSaved: (String? val) {
                              // validator에서 걸러주기 때문에 null일 수 없음 => !를 사용
                              endTime = int.parse(val!);
                            },
                            startInitialValue: startTime?.toString() ??
                                '', // null 값인 경우 initialValue를 ''로 설정
                            endInitialValue: endTime?.toString() ??
                                '', // null 값인 경우 initialValue를 ''로 설정
                          ),
                          SizedBox(height: 16.0),
                          _Content(
                            onSaved: (String? val) {
                              content = val;
                            },
                            initialValue: content ??
                                '', // null 값인 경우 initialValue를 ''로 설정
                          ),
                          SizedBox(height: 16.0),
                          FutureBuilder<List<CategoryColor>>(
                              // dependency injection
                              future:
                                  GetIt.I<LocalDatabase>().getCategoryColors(),
                              builder: (context, snapshot) {
                                // default color 결정
                                if (snapshot.hasData &&
                                    selectedColorId == null &&
                                    snapshot.data!.isNotEmpty) {
                                  selectedColorId = snapshot
                                      .data![0].id; // 데이터에 있는 첫번째 값을 ID로 설정
                                }

                                return _ColorPicker(
                                  // !는 절대 null이 아닌 상황에만 사용해야함(에러 발생)
                                  colors:
                                      snapshot.hasData ? snapshot.data! : [],
                                  selectedColorId: selectedColorId,
                                  colorIdSetter: (int id) {
                                    setState(() {
                                      selectedColorId = id;
                                    });
                                  },
                                );
                              }),
                          SizedBox(height: 8.0),
                          _SaveButton(
                            onPressed: onSavePressed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void onSavePressed() async {
    // formKey는 생성이 됐지만, Form 위젯과 결합이 안됐을 때
    if (formKey.currentState == null) {
      return;
    }

    // .validate() => Form 영역에 속하는 모든 TextFormField의 validator 함수가 실행됨
    if (formKey.currentState!.validate()) {
      // 에러 X
      formKey.currentState!.save(); // await는 사용하지 않아도 됨

      if (widget.scheduleId == null) {
        // 신규 저장 건인 경우
        final key = await GetIt.I<LocalDatabase>().createSchedule(
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          ),
        );
      } else {
        // 기전 데이터 저장(update) 건인 경우
        await GetIt.I<LocalDatabase>().updateScheduleById(
          widget.scheduleId!,
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          ),
        );
      }

      // bottom sheet close
      Navigator.of(context).pop();
    } else {
      // 에러 O
      print('에러 발생');
    }
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;

  const _Time({
    required this.onStartSaved,
    required this.onEndSaved,
    required this.startInitialValue,
    required this.endInitialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: '시작 시간',
            isTime: true,
            onSaved: onStartSaved,
            initialValue: startInitialValue,
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: CustomTextField(
            label: '마감 시간',
            isTime: true,
            onSaved: onEndSaved,
            initialValue: endInitialValue,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  const _Content({
    required this.onSaved,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        isTime: false,
        onSaved: onSaved,
        initialValue: initialValue,
      ),
    );
  }
}

typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker({
    required this.colors,
    required this.selectedColorId,
    required this.colorIdSetter,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Row 대신 Wrap을 사용하면, 위젯이 화면을 넘어가는 경우 자동으로 줄바꿈을 해줌
    return Wrap(
      spacing: 8.0, // 좌우 간격
      runSpacing: 10.0, // 상하 간격
      children: colors
          .map(
            (e) => GestureDetector(
              // 해당 색상을 클릭할 때마다 선택 처리
              onTap: () {
                // 선택될 때마다 ID 전달
                colorIdSetter(e.id);
              },
              child: renderColor(
                e,
                selectedColorId == e.id, // 해당 color가 선택됐는지, 아닌지 판단
              ),
            ),
          )
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse(
            'FF${color.hexCode}',
            radix: 16, // color는 16진수이기 떄문에 16진수로 변환
          ),
        ),
        border: isSelected
            ? Border.all(
                color: Colors.black,
                width: 4.0,
              )
            : null,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: Text(
              '저장',
            ),
          ),
        ),
      ],
    );
  }
}
