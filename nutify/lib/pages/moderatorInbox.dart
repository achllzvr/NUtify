import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nutify/models/moderatorRequests.dart';

class ModeratorInbox extends StatefulWidget {
  const ModeratorInbox({super.key});

  @override
  State<ModeratorInbox> createState() => _ModeratorInboxState();
}

class _ModeratorInboxState extends State<ModeratorInbox> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF35408E), Color(0xFF1A2049)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD418),
          unselectedLabelColor: Colors.white,
          indicatorColor: const Color(0xFFFFD418),
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Account Approvals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _requestsTab(),
          _accountApprovalsTab(),
        ],
      ),
    );
  }

  Widget _requestsTab() {
    return FutureBuilder<List<ModeratorRequestItem>>(
      future: ModeratorRequestsApi.fetchRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(
            child: Text('No moderator requests found', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final item = list[i];
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
          },
        );
      },
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
                                onPressed: () => _updateVerification(u.userId, 2),
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
                                  onPressed: () => _updateVerification(u.userId, 1),
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

Future<List<_UserApprovalItem>> _fetchPendingUsers() async {
  final res = await http.post(
    Uri.parse('https://nutify.site/api.php?action=getPendingUsers'),
    headers: {'Content-Type': 'application/json'},
    body: '{}',
  );
  if (res.statusCode != 200) return [];
  try {
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
  final res = await http.post(
    Uri.parse('https://nutify.site/api.php?action=updateUserVerification'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'user_id': userId, 'is_verified': value}),
  );
}
