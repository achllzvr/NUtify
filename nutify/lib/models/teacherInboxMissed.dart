class TeacherInboxMissed {
  final String id;
  final String studentName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;

  TeacherInboxMissed({
    required this.id,
    required this.studentName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
  });

  factory TeacherInboxMissed.fromJson(Map<String, dynamic> json) {
    return TeacherInboxMissed(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      department: json['department'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      scheduleTime: json['schedule_time'] ?? '',
    );
  }

  static Future<List<TeacherInboxMissed>> getTeacherInboxMisseds() async {
    // TODO: Implement API call to fetch teacher's missed appointments
    // For now, return mock data
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    return [
      TeacherInboxMissed(
        id: '1',
        studentName: 'Sarah Wilson',
        department: 'SACE',
        scheduleDate: 'June 8',
        scheduleTime: '10:00 am',
      ),
    ];
  }
}
