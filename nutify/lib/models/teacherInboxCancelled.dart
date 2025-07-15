class TeacherInboxCancelled {
  final String id;
  final String studentName;
  final String faculty;
  final String scheduleDate;
  final String scheduleTime;

  TeacherInboxCancelled({
    required this.id,
    required this.studentName,
    required this.faculty,
    required this.scheduleDate,
    required this.scheduleTime,
  });

  factory TeacherInboxCancelled.fromJson(Map<String, dynamic> json) {
    return TeacherInboxCancelled(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      faculty: json['faculty'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      scheduleTime: json['schedule_time'] ?? '',
    );
  }

  static Future<List<TeacherInboxCancelled>> getTeacherInboxCancelleds() async {
    // TODO: Implement API call to fetch teacher's cancelled appointments
    // For now, return mock data
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    return [
      TeacherInboxCancelled(
        id: '1',
        studentName: 'Robert Johnson',
        faculty: 'SACE',
        scheduleDate: 'June 10',
        scheduleTime: '2:00 pm',
      ),
    ];
  }
}
