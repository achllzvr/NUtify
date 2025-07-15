class TeacherInboxPending {
  final String id;
  final String studentName;
  final String faculty;
  final String scheduleDate;
  final String scheduleTime;

  TeacherInboxPending({
    required this.id,
    required this.studentName,
    required this.faculty,
    required this.scheduleDate,
    required this.scheduleTime,
  });

  factory TeacherInboxPending.fromJson(Map<String, dynamic> json) {
    return TeacherInboxPending(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      faculty: json['faculty'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      scheduleTime: json['schedule_time'] ?? '',
    );
  }

  static Future<List<TeacherInboxPending>> getTeacherInboxPendings() async {
    // TODO: Implement API call to fetch teacher's pending appointments
    // For now, return mock data
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    return [
      TeacherInboxPending(
        id: '1',
        studentName: 'Achilles Vonn Rabina',
        faculty: 'SACE',
        scheduleDate: 'June 13',
        scheduleTime: '9:00 am',
      ),
      TeacherInboxPending(
        id: '2',
        studentName: 'Maria Garcia',
        faculty: 'SACE',
        scheduleDate: 'June 16',
        scheduleTime: '11:00 am',
      ),
    ];
  }
}
