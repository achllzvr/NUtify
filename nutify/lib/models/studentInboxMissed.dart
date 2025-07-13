class StudentInboxMissed {
  final String name;
  final String id;
  final String timestamp;
  final bool isSelected;

  StudentInboxMissed({
    required this.name,
    required this.id,
    required this.timestamp,
    this.isSelected = false,
  });

  static List<StudentInboxMissed> getStudentInboxMissed() {
    List<StudentInboxMissed> studentInboxMissed = [];

    studentInboxMissed.add(
      StudentInboxMissed(
        name: 'Dr. Smith',
        id: '001',
        timestamp: '2023-10-01 10:00',
        isSelected: false,
      ),
    );

    return studentInboxMissed;
  }
}
