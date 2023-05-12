import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isTime; // true => 시간 || false => 내용
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  const CustomTextField({
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TextField = inputBox, 해당 영역 클릭 시, keyboard Open
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime)
          Expanded(
            child: renderTextField(),
          ),
      ],
    );
  }

  Widget renderTextField() {
    // TextFormField => front에서 back으로 값을 넘겨줄 때 사용
    return TextFormField(
      // null이 리턴되면 에러 X, 에러 O이면 에러를 String 값으로 리턴
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '값을 입력해주세요.';
        }

        // 아래의 inputFormatters에서 걸러주기 때문에 isTime이 true인 경우 String을 int로 변환이 가능할 것임
        if (isTime) {
          int time = int.parse(val);

          if (time <= 0) {
            return '0보다 큰 숫자를 입력해주세요.';
          }
          if (time >= 24) {
            return '24보다 작은 숫자를 입력해주세요.';
          }
        } else {
          // 아래 로직은 maxLength에서 방어가 가능하긴 함
          if (val.length > 500) {
            return '500자 이하의 글자를 입력해주세요.';
          }
        }

        return null;
      },
      // 저장 시, TextFormField 상위에 있는 Form에서 save 함수가 불렸을 때, 실행
      onSaved: onSaved,
      cursorColor: Colors.grey,
      initialValue: initialValue, // 초기값 지정
      // TextInputType.number => number 키보드 호출
      // TextInputType.multiline => 기본 키보드 호출
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      // input 필터링
      inputFormatters: isTime
          ? [
              FilteringTextInputFormatter.digitsOnly, // 숫자만 입력
            ]
          : [],
      // maxLines: null => 줄바꿈 무한
      maxLines: isTime ? 1 : null,
      expands: !isTime, // isTime ? false : true 와 같은 로직
      // maxLength: 500, // 최대 입력 가능한 값 (아래 숫자로 표기됨)
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
        suffixText: isTime ? '시' : null, // 클릭할 때마다 보이는 접미사
      ),
    );
  }
}
