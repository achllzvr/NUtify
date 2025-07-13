class StudentInboxCompleted {
  final String name;
  final String id;
  final String timestamp;
  final bool isSelected;

  StudentInboxCompleted({
    required this.name,
    required this.id,
    required this.timestamp,
    this.isSelected = false,
  });

  static List<StudentInboxCompleted> getStudentInboxCompleted() {
    List<StudentInboxCompleted> studentInboxCompleted = [];

    studentInboxCompleted.add(StudentInboxCompleted(name: 'Prof. Johnson', id: '002', timestamp: '2023-10-02 11:00', isSelected: false));

    return studentInboxCompleted;
  }

}