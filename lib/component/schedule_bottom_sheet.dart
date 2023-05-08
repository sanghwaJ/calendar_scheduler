import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet({Key? key}) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  // 값을 저장하기 위해 관리하는 변수
  int? startTime;
  int? endTime;
  String? content;

  @override
  Widget build(BuildContext context) {
    // viewInsets => 전체 스크린 화면 중 System UI에 의해 가려진 크기 리턴
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        // 빈 화면 클릭 시, Focus out
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
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
                autovalidateMode: AutovalidateMode.always,
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
                    ),
                    SizedBox(height: 16.0),
                    _Content(
                      onSaved: (String? val) {
                        content = val;
                      },
                    ),
                    SizedBox(height: 16.0),
                    _ColorPicker(),
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
      ),
    );
  }

  void onSavePressed() {
    // formKey는 생성이 됐지만, Form 위젯과 결합이 안됐을 때
    if (formKey.currentState == null) {
      return;
    }

    // .validate() => Form 영역에 속하는 모든 TextFormField의 validator 함수가 실행됨
    if (formKey.currentState!.validate()) {
      // 에러 X
      print('에러 없음');
      formKey.currentState!.save(); // await는 사용하지 않아도 됨
      print('startTime $startTime');
      print('endTime $endTime');
      print('content $content');
    } else {
      // 에러 O
      print('에러 발생');
    }
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;

  const _Time({
    required this.onStartSaved,
    required this.onEndSaved,
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
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;

  const _Content({
    required this.onSaved,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        isTime: false,
        onSaved: onSaved,
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Row 대신 Wrap을 사용하면, 위젯이 화면을 넘어가는 경우 자동으로 줄바꿈을 해줌
    return Wrap(
      spacing: 8.0, // 좌우 간격
      runSpacing: 10.0, // 상하 간격
      children: [
        renderColor(Colors.red),
        renderColor(Colors.orange),
        renderColor(Colors.yellow),
        renderColor(Colors.green),
        renderColor(Colors.blue),
        renderColor(Colors.indigo),
        renderColor(Colors.purple),
      ],
    );
  }

  Widget renderColor(Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
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
