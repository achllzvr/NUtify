class RecentProfessor {
  final String name;
  final String id;

  RecentProfessor({required this.name, required this.id});

  static List<RecentProfessor> getRecentProfessors() {
    List<RecentProfessor> recentProfessors = [];

    recentProfessors.add(RecentProfessor(name: 'Dr. Smith', id: '001'));
    recentProfessors.add(RecentProfessor(name: 'Prof. Johnson', id: '002'));
    recentProfessors.add(RecentProfessor(name: 'Dr. Brown', id: '003'));
    recentProfessors.add(RecentProfessor(name: 'Prof. Davis', id: '004'));
    recentProfessors.add(RecentProfessor(name: 'Dr. Wilson', id: '005'));

    return recentProfessors;
  }
}
