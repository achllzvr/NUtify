class StudentSearch {
  final String name;
  final String id;
  final String department;

  StudentSearch({
    required this.name,
    required this.id,
    required this.department,
  });

  static List<StudentSearch> searchProfessors() {
    List<StudentSearch> professorList = [];

    professorList.add(
      StudentSearch(
        name: 'Dr. Smith',
        id: '001',
        department: 'Computer Science',
      ),
    );
    professorList.add(
      StudentSearch(
        name: 'Prof. Johnson',
        id: '002',
        department: 'Mathematics',
      ),
    );
    professorList.add(
      StudentSearch(name: 'Dr. Brown', id: '003', department: 'Physics'),
    );
    professorList.add(
      StudentSearch(name: 'Prof. Davis', id: '004', department: 'Chemistry'),
    );
    professorList.add(
      StudentSearch(name: 'Dr. Wilson', id: '005', department: 'Biology'),
    );

    return professorList;
  }
}
