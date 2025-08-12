import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nutify/models/moderatorRequests.dart';
import 'package:nutify/pages/moderatorHome.dart';
import 'package:nutify/pages/moderatorProfile.dart';
import 'package:intl/intl.dart';

class ModeratorInbox extends StatefulWidget {
  const ModeratorInbox({super.key});

  @override
  State<ModeratorInbox> createState() => _ModeratorInboxState();
}

class _ModeratorInboxState extends State<ModeratorInbox> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  // New controllers for specific tabs
  final TextEditingController _studentsLogSearchCtrl = TextEditingController();
  final TextEditingController _otsSearchCtrl = TextEditingController();
  DateTime? _studentsLogDateFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _studentsLogSearchCtrl.dispose();
    _otsSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _moderatorAppBar(context),
      body: Column(
        children: [
          _navigationalTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _studentsLogTab(),
                _onTheSpotTab(),
                _accountApprovalsTab(),
                _accountsOnHoldTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _moderatorAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: const Text(
          'Moderator Inbox',
          style: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF35408E), const Color(0xFF1A2049)],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: const [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            if (ModalRoute.of(context)?.settings.name == '/moderatorProfile') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('You are already on the Profile page', style: TextStyle(fontFamily: 'Arimo')),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF35408E),
                ),
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ModeratorProfile(),
                  settings: const RouteSettings(name: '/moderatorProfile'),
                ),
                (Route<dynamic> route) => false,
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 25.0),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/icons/profile.png'),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModeratorHome(),
                      settings: const RouteSettings(name: '/moderatorHome'),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.inbox, color: Color(0xFFFFD418)),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name == '/moderatorInbox' ||
                      context.widget.runtimeType == ModeratorInbox) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('You are already on the Inbox page', style: TextStyle(fontFamily: 'Arimo')),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF35408E),
                      ),
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ModeratorInbox(),
                        settings: const RouteSettings(name: '/moderatorInbox'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigationalTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFFD418),
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFFFFD418),
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Students Log'),
          Tab(text: 'On-The-Spot Requests'),
          Tab(text: 'Account Approvals'),
          Tab(text: 'Accounts on Hold'),
        ],
      ),
    );
  }

  // Students Log tab: completed appointments, grouped by date, with search + date filter
  Widget _studentsLogTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _studentsLogSearchCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search students or faculty…',
                    hintStyle: const TextStyle(fontFamily: 'Arimo'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: _studentsLogDateFilter == null
                    ? 'Filter by date'
                    : 'Filtered: ${DateFormat('y-MM-dd').format(_studentsLogDateFilter!)} (tap to change)',
                icon: const Icon(Icons.event, color: Color(0xFF35408E)),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _studentsLogDateFilter ?? now,
                    firstDate: DateTime(now.year - 2),
                    lastDate: DateTime(now.year + 2),
                  );
                  if (picked != null) {
                    setState(() => _studentsLogDateFilter = picked);
                  }
                },
              ),
              if (_studentsLogDateFilter != null)
                IconButton(
                  tooltip: 'Clear date filter',
                  icon: const Icon(Icons.clear, color: Colors.redAccent),
                  onPressed: () => setState(() => _studentsLogDateFilter = null),
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<StudentsLogItem>>(
            future: ModeratorRequestsApi.fetchStudentsLog(date: _studentsLogDateFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var items = snapshot.data ?? [];
              final q = _studentsLogSearchCtrl.text.trim().toLowerCase();
              if (q.isNotEmpty) {
                items = items
                    .where((e) => e.studentName.toLowerCase().contains(q) || e.teacherName.toLowerCase().contains(q))
                    .toList();
              }
              if (items.isEmpty) {
                return const Center(
                  child: Text('No completed visits found', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey)),
                );
              }

              // Group by date (YYYY-MM-DD)
              final Map<String, List<StudentsLogItem>> grouped = {};
              for (final it in items) {
                final dateKey = (it.appointmentDate.split(' ').first);
                grouped.putIfAbsent(dateKey, () => []).add(it);
              }
              final keys = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a)); // latest first

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: keys.length,
                itemBuilder: (context, idx) {
                  final k = keys[idx];
                  DateTime? d;
                  try { d = DateTime.parse(k); } catch (_) {}
                  final pretty = d != null ? DateFormat('MMMM d, y').format(d) : k;
                  final dayItems = grouped[k]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(pretty, style: const TextStyle(fontFamily: 'Arimo', fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      ...dayItems.map(_studentsLogCard).toList(),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget _studentsLogCard(StudentsLogItem item) {
    String when = item.appointmentDate;
    try {
      final dt = DateTime.parse(item.appointmentDate.replaceFirst(' ', 'T'));
      when = DateFormat('MMMM d, y • h:mm a').format(dt);
    } catch (_) {}
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.studentName, style: const TextStyle(fontFamily: 'Arimo', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Faculty: ${item.teacherName}', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(when, style: const TextStyle(fontFamily: 'Arimo')),
          if (item.reason.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Reason: ${item.reason}', style: const TextStyle(fontFamily: 'Arimo')),
          ]
        ],
      ),
    );
  }

  Widget _requestCard(ModeratorRequestItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.teacherName, style: const TextStyle(fontFamily: 'Arimo', fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Student: ${item.studentName}', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text('Reason: ${item.reason}', style: const TextStyle(fontFamily: 'Arimo')),
          const SizedBox(height: 6),
          Text('Status: ${item.status}', style: const TextStyle(fontFamily: 'Arimo')),
        ],
      ),
    );
  }

  // On-The-Spot tab with search
  Widget _onTheSpotTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _otsSearchCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search on-the-spot requests…',
              hintStyle: const TextStyle(fontFamily: 'Arimo'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ModeratorRequestItem>>(
            future: ModeratorRequestsApi.fetchOnTheSpotRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var list = snapshot.data ?? [];
              final q = _otsSearchCtrl.text.trim().toLowerCase();
              if (q.isNotEmpty) {
                list = list
                    .where((e) => e.studentName.toLowerCase().contains(q) || e.teacherName.toLowerCase().contains(q) || e.reason.toLowerCase().contains(q))
                    .toList();
              }
              if (list.isEmpty) {
                return const Center(
                  child: Text('No on-the-spot requests found', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _requestCard(list[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _accountApprovalsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search users…',
              hintStyle: const TextStyle(fontFamily: 'Arimo'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<_UserApprovalItem>>( 
            future: _fetchPendingUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var users = snapshot.data ?? [];
              final q = _searchController.text.trim().toLowerCase();
              if (q.isNotEmpty) {
                users = users.where((u) => u.name.toLowerCase().contains(q)).toList();
              }
              if (users.isEmpty) {
                return const Center(child: Text('No pending accounts', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey)));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final u = users[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _updateVerification(u.userId, 2);
                                  if (mounted) {
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Moved to hold')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Hold', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _updateVerification(u.userId, 1);
                                    if (mounted) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Verified')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Verify', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget _accountsOnHoldTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search users…',
              hintStyle: const TextStyle(fontFamily: 'Arimo'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<_UserApprovalItem>>( 
            future: _fetchHoldUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var users = snapshot.data ?? [];
              final q = _searchController.text.trim().toLowerCase();
              if (q.isNotEmpty) {
                users = users.where((u) => u.name.toLowerCase().contains(q)).toList();
              }
              if (users.isEmpty) {
                return const Center(child: Text('No accounts on hold', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey)));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final u = users[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _updateVerification(u.userId, 1);
                                    if (mounted) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Verified')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Verify', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class _UserApprovalItem {
  final int userId;
  final String name;
  _UserApprovalItem({required this.userId, required this.name});
}

Future<List<_UserApprovalItem>> _fetchHoldUsers() async {
  try {
    final res = await http.get(Uri.parse('https://nutify.site/api.php?action=getAccountsOnHold'));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    final list = (data['users'] ?? data['data'] ?? []) as List;
    return list
        .map((e) => _UserApprovalItem(
              userId: int.tryParse(e['user_id']?.toString() ?? '') ?? 0,
              name: (e['full_name'] ?? '${e['user_fn'] ?? ''} ${e['user_ln'] ?? ''}').trim(),
            ))
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> _updateVerification(int userId, int value) async {
  try {
    await http.post(
      Uri.parse('https://nutify.site/api.php?action=updateUserVerification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'is_verified': value}),
    );
  } catch (_) {}
}

Future<List<_UserApprovalItem>> _fetchPendingUsers() async {
  try {
    final res = await http.get(Uri.parse('https://nutify.site/api.php?action=getPendingUsers'));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    final list = (data['users'] ?? data['data'] ?? []) as List;
    return list
        .map((e) => _UserApprovalItem(
              userId: int.tryParse(e['user_id']?.toString() ?? '') ?? 0,
              name: (e['full_name'] ?? '${e['user_fn'] ?? ''} ${e['user_ln'] ?? ''}').trim(),
            ))
        .toList();
  } catch (_) {
    return [];
  }
}