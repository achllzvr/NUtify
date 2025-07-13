class StudentInboxPending {
  final String name;
  final String id;
  final String timestamp;
  final bool isSelected;

  StudentInboxPending({
    required this.name,
    required this.id,
    required this.timestamp,
    this.isSelected = false,
  });

  static List<StudentInboxPending> getStudentInboxPendings() {
    List<StudentInboxPending> studentInboxPendings = [];

    studentInboxPendings.add(
      StudentInboxPending(
        name: 'Dr. Brown',
        id: '003',
        timestamp: '2023-10-03 12:00',
        isSelected: false,
      ),
    );

    return studentInboxPendings;
  }
}
