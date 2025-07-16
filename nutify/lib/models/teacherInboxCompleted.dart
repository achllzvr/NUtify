class TeacherInboxCompleted {
  final String id;
  final String studentName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;

  TeacherInboxCompleted({
    required this.id,
    required this.studentName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
  });

  factory TeacherInboxCompleted.fromJson(Map<String, dynamic> json) {
    return TeacherInboxCompleted(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      department: json['department'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      scheduleTime: json['schedule_time'] ?? '',
    );
  }

  static Future<List<TeacherInboxCompleted>> getTeacherInboxCompleteds() async {
    // TODO: Implement API call to fetch teacher's completed appointments
    // For now, return mock data
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    return [
      TeacherInboxCompleted(
        id: '1',
        studentName: 'Michael Brown',
        department: 'SACE',
        scheduleDate: 'June 5',
        scheduleTime: '3:00 pm',
      ),
      TeacherInboxCompleted(
        id: '2',
        studentName: 'Emily Davis',
        department: 'SACE',
        scheduleDate: 'June 7',
        scheduleTime: '1:30 pm',
      ),
    ];
  }
}
