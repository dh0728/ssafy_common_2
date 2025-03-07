import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';
import 'package:kkulkkulk/features/profile/view_models/arm_span_view_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'camera_screen.dart';
import 'package:kkulkkulk/features/profile/data/models/arm_span_model.dart'; // ✅ 추가
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';

class ProfileScreenEdit extends ConsumerStatefulWidget {
  const ProfileScreenEdit({super.key});

  @override
  _ProfileScreenEditState createState() => _ProfileScreenEditState();
}

class _ProfileScreenEditState extends ConsumerState<ProfileScreenEdit> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _armSpanController = TextEditingController();
  DateTime? _selectedStartDate;
  bool _isCalendarVisible = false;

  @override
  void initState() {
    super.initState();

    final userProfile = ref.read(profileProvider).value;
    if (userProfile != null) {
      _nicknameController.text = userProfile.nickname;
      _heightController.text = userProfile.height.toString();
      _armSpanController.text = userProfile.armSpan.toString();
      _selectedStartDate = userProfile.startDate;
    }
  }

  /// 🔥 달력 가시성 토글
  void _toggleCalendarVisibility() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  /// 🔥 프로필 저장
  void _saveProfile() {
    final double? newHeight = double.tryParse(_heightController.text);
    final double? newArmSpan = double.tryParse(_armSpanController.text);
    final userProfile = ref.read(profileProvider).value;

    if (newHeight != null && newArmSpan != null && userProfile != null) {
      final updatedProfile = UserProfile(
        nickname: _nicknameController.text,
        height: newHeight,
        armSpan: newArmSpan,
        profileImageUrl: userProfile.profileImageUrl, // ✅ 기존 값 유지
        userTier: userProfile.userTier, // ✅ 기존 티어 유지
        dday: userProfile.dday, // ✅ 기존 D-Day 유지
        startDate: _selectedStartDate,
      );

      ref.read(profileProvider.notifier).updateUserProfile(updatedProfile);
      Navigator.pop(context); // ✅ 저장 후 화면 닫기
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("키와 팔길이를 올바르게 입력하세요!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(armSpanViewModelProvider, (previous, next) {
      debugPrint("📌 [DEBUG] ref.listen() 감지됨: 이전 상태=$previous, 새로운 상태=$next");

      if (next.hasValue && next.value != null) {
        final armSpan = next.value!.armSpan;
        debugPrint("📌 [DEBUG] UI 업데이트 실행됨: 새 팔길이 값=$armSpan");

        setState(() {
          _armSpanController.text = armSpan.toString();
        });

        debugPrint("📌 [DEBUG] UI 업데이트 후 입력 필드 값: ${_armSpanController.text}");
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(title: '프로필 수정'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("닉네임", _nicknameController),
            const SizedBox(height: 24),
            _buildStartDateSelector(),
            const SizedBox(height: 24),
            _buildBodyMetricsInput(ref.watch(armSpanViewModelProvider)),
            const SizedBox(height: 16),
            _buildMeasureButton(context,
                double.tryParse(_heightController.text) ?? 0.0) // 🔥 측정 버튼 추가
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 248, 139, 5),
              padding: const EdgeInsets.all(16)),
          child: const Text('저장',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  /// 🔹 **텍스트 입력 필드 공통 위젯**
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '값을 입력하세요.',
          ),
        ),
      ],
    );
  }

  /// 🔹 **클라이밍 시작일 선택 UI**
  Widget _buildStartDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('클라이밍 시작일',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _toggleCalendarVisibility,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedStartDate != null
                      ? "${_selectedStartDate!.year}-${_selectedStartDate!.month}-${_selectedStartDate!.day}"
                      : "클라이밍 시작일을 선택해주세요.",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _selectedStartDate ?? DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(_selectedStartDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedStartDate = selectedDay;
                _isCalendarVisible = false;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 242, 200, 148),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 248, 139, 5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          crossFadeState: _isCalendarVisible
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  /// 🔹 **키 & 팔길이 입력 UI**
  Widget _buildBodyMetricsInput(AsyncValue<ArmSpanResult> armSpanState) {
    return Row(
      children: [
        Expanded(child: _buildNumberTextField("키 (cm)", _heightController)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildNumberTextField(
                "팔길이 (cm)", _armSpanController)), // 🔥 직접 입력 가능
      ],
    );
  }

  /// 🔹 **숫자 입력 필드 공통 위젯**
  Widget _buildNumberTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '숫자를 입력하세요.',
          ),
        ),
      ],
    );
  }

  /// 🔹 **측정 버튼 추가**
  Widget _buildMeasureButton(BuildContext context, double height) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _openCameraScreen(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
        child: const Text(
          '팔길이 측정',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  /// 🔥 카메라 화면 열기
  void _openCameraScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onImageCaptured: (imagePath) {
            _sendImageToServer(imagePath);
          },
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _sendImageToServer(String imagePath) async {
    final double? height = double.tryParse(_heightController.text);
    if (height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("키를 입력한 후 측정을 진행해주세요.")),
      );
      return;
    }

    try {
      await ref
          .read(armSpanViewModelProvider.notifier)
          .measureArmSpan(imagePath, height);

      // ✅ UI 강제 업데이트 (이전 값이 남아있을 수 있음)
      Future.delayed(const Duration(milliseconds: 300), () {
        debugPrint(
            "📌 [DEBUG] 팔길이 값 UI 업데이트: ${ref.read(armSpanViewModelProvider).value?.armSpan}");
        setState(() {
          final result = ref.read(armSpanViewModelProvider).value;
          if (result != null) {
            _armSpanController.text = result.armSpan.toString();
          }
        });
      });
    } catch (e) {
      debugPrint("❌ 팔길이 측정 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("팔길이 측정에 실패했습니다.")),
      );
    }
  }
}
