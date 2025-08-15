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
  // Pagination state per tab
  int _requestsPage = 0;
  int _approvalsPage = 0;
  int _onHoldPage = 0;

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
      automaticallyImplyLeading: false,
      title: Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: const Text(
          'Inbox',
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
          Tab(text: 'Daily Log'),
          Tab(text: 'Requests'),
          Tab(text: 'Approvals'),
          Tab(text: 'On Hold'),
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
                    builder: (context, child) {
                      final theme = Theme.of(context);
                      return Theme(
                        data: theme.copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF35408E), // header bg & active
                            secondary: Color(0xFFFFD418),
                            onPrimary: Colors.white,      // header text
                            onSurface: Color(0xFF1A2049), // body text
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF35408E), // buttons
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
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
                  child: Text('No completed appointments for today yet', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey)),
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

              // Limit to 2 most recent days when no date filter is applied
              final keysToShow = _studentsLogDateFilter == null ? keys.take(2).toList() : keys;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: keysToShow.length,
                itemBuilder: (context, idx) {
                  final k = keysToShow[idx];
                  DateTime? d;
                  try { d = DateTime.parse(k); } catch (_) {}
                  final pretty = d != null ? DateFormat('MMMM d, y').format(d) : k;
                  final dayItems = grouped[k]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
      width: double.infinity,
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

  // Status gradient colors to match Student/Teacher roles
  List<Color> _getStatusGradientColors(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const [Color(0xFF2196F3), Color(0xFF0D47A1)]; // Blue
      case 'declined':
        return const [Color(0xFFF44336), Color(0xFFB71C1C)]; // Red
      case 'missed':
        return const [Color(0xFFFF9800), Color(0xFFE65100)]; // Orange
      case 'completed':
        return const [Color(0xFF4CAF50), Color(0xFF2E7D32)]; // Green
      case 'accepted':
        return const [Color(0xFF4CAF50), Color(0xFF2E7D32)]; // Green (same as completed)
      default:
        return const [Color(0xFF9E9E9E), Color(0xFF616161)]; // Grey fallback
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  Widget _buildStatusBadge(String status) {
    final colors = _getStatusGradientColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: colors.first.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        _capitalize(status),
        style: const TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _requestCard(ModeratorRequestItem item) {
    String created = item.createdAt;
    try {
      final dt = DateTime.parse(item.createdAt.replaceFirst(' ', 'T'));
      created = DateFormat('MMMM d, y • h:mm a').format(dt);
    } catch (_) {}
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
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontFamily: 'Arimo')),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('Timestamp: $created', style: const TextStyle(fontFamily: 'Arimo')),
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
            onChanged: (_) => setState(() { _requestsPage = 0; }),
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
                  child: Text('No on-the-spot requests made today', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey)),
                );
              }

              // Pagination: 10 per page
              final total = list.length;
              final totalPages = (total + 9) ~/ 10;
              int page = _requestsPage;
              if (page >= totalPages) page = totalPages - 1;
              if (page < 0) page = 0;
              final start = page * 10;
              final end = (start + 10 > total) ? total : start + 10;
              final pageItems = list.sublist(start, end);

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: pageItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _requestCard(pageItems[i]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Page ${page + 1} of $totalPages', style: const TextStyle(fontFamily: 'Arimo')),
                        Row(children: [
                          OutlinedButton(
                            onPressed: page > 0 ? () => setState(() => _requestsPage = page - 1) : null,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: page < totalPages - 1 ? () => setState(() => _requestsPage = page + 1) : null,
                            child: const Text('Next'),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
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
            onChanged: (_) => setState(() { _approvalsPage = 0; }),
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

              // Pagination: 10 per page
              final total = users.length;
              final totalPages = (total + 9) ~/ 10;
              int page = _approvalsPage;
              if (page >= totalPages) page = totalPages - 1;
              if (page < 0) page = 0;
              final start = page * 10;
              final end = (start + 10 > total) ? total : start + 10;
              final pageItems = users.sublist(start, end);

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: pageItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final u = pageItems[i];
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
                                            SnackBar(content: const Text('Moved to hold'), backgroundColor: Colors.red.shade600),
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
                                              SnackBar(content: const Text('Verified'), backgroundColor: Colors.green.shade600),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Page ${page + 1} of $totalPages', style: const TextStyle(fontFamily: 'Arimo')),
                        Row(children: [
                          OutlinedButton(
                            onPressed: page > 0 ? () => setState(() => _approvalsPage = page - 1) : null,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: page < totalPages - 1 ? () => setState(() => _approvalsPage = page + 1) : null,
                            child: const Text('Next'),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
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
            onChanged: (_) => setState(() { _onHoldPage = 0; }),
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

              // Pagination: 10 per page
              final total = users.length;
              final totalPages = (total + 9) ~/ 10;
              int page = _onHoldPage;
              if (page >= totalPages) page = totalPages - 1;
              if (page < 0) page = 0;
              final start = page * 10;
              final end = (start + 10 > total) ? total : start + 10;
              final pageItems = users.sublist(start, end);

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: pageItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final u = pageItems[i];
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
                                              SnackBar(content: const Text('Verified'), backgroundColor: Colors.green.shade600),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Page ${page + 1} of $totalPages', style: const TextStyle(fontFamily: 'Arimo')),
                        Row(children: [
                          OutlinedButton(
                            onPressed: page > 0 ? () => setState(() => _onHoldPage = page - 1) : null,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: page < totalPages - 1 ? () => setState(() => _onHoldPage = page + 1) : null,
                            child: const Text('Next'),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
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