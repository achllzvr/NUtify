class TeacherHomeAppointments {
  final String id;
  final String studentName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;

  TeacherHomeAppointments({
    required this.id,
    required this.studentName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
  });

  factory TeacherHomeAppointments.fromJson(Map<String, dynamic> json) {
    return TeacherHomeAppointments(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      department: json['department'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      scheduleTime: json['schedule_time'] ?? '',
    );
  }

  static Future<List<TeacherHomeAppointments>> getTeacherHomeAppointments() async {
    // TODO: Implement API call to fetch teacher's upcoming appointments
    // For now, return mock data
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    return [
      TeacherHomeAppointments(
        id: '1',
        studentName: 'Achilles Vonn Rabina',
        department: 'SACE',
        scheduleDate: 'June 13',
        scheduleTime: '9:00 am',
      ),
      TeacherHomeAppointments(
        id: '2',
        studentName: 'John Doe',
        department: 'SACE',
        scheduleDate: 'June 14',
        scheduleTime: '10:30 am',
      ),
      TeacherHomeAppointments(
        id: '3',
        studentName: 'Jane Smith',
        department: 'SACE',
        scheduleDate: 'June 15',
        scheduleTime: '2:00 pm',
      ),
    ];
  }
}
