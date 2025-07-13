class StudentInboxCancelled {
  final String name;
  final String id;
  final String timestamp;
  final bool isSelected;

  StudentInboxCancelled({
    required this.name,
    required this.id,
    required this.timestamp,
    this.isSelected = false,
  });

  static List<StudentInboxCancelled> getStudentInboxCancelled() {
    List<StudentInboxCancelled> studentInboxCancelled = [];

    studentInboxCancelled.add(
      StudentInboxCancelled(
        name: 'Dr. Green',
        id: '003',
        timestamp: '2023-10-03 12:00',
        isSelected: false,
      ),
    );

    return studentInboxCancelled;
  }
}
