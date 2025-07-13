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

    return studentInboxCancelled;
  }

}