class StudentHomeAppointments {
  final String name;
  final String id;
  final String timestamp;
  final bool isSelected;

  StudentHomeAppointments({
    required this.name,
    required this.id,
    required this.timestamp,
    this.isSelected = false,
  });

  static List<StudentHomeAppointments> getStudentHomeAppointments() {
    List<StudentHomeAppointments> studentHomeAppointments = [];

    studentHomeAppointments.add(
      StudentHomeAppointments(
        name: 'Dr. Smith',
        id: '001',
        timestamp: '2023-10-01 10:00',
        isSelected: false,
      ),
    );
    studentHomeAppointments.add(
      StudentHomeAppointments(
        name: 'Prof. Johnson',
        id: '002',
        timestamp: '2023-10-02 11:00',
        isSelected: false,
      ),
    );
    studentHomeAppointments.add(
      StudentHomeAppointments(
        name: 'Dr. Brown',
        id: '003',
        timestamp: '2023-10-03 12:00',
        isSelected: false,
      ),
    );

    return studentHomeAppointments;
  }
}
