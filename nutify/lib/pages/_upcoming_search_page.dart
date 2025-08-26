import 'package:flutter/material.dart';
import 'package:nutify/models/studentHomeAppointments.dart';
import 'package:intl/intl.dart';

class UpcomingSearchPage extends StatefulWidget {
  final Future<List<StudentHomeAppointments>>? initialFuture;
  const UpcomingSearchPage({super.key, required this.initialFuture});

  @override
  State<UpcomingSearchPage> createState() => _UpcomingSearchPageState();
}

class _UpcomingSearchPageState extends State<UpcomingSearchPage> {
  final TextEditingController _search = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      final v = _search.text;
      if (v != _q) setState(() => _q = v);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF35408E), Color(0xFF1A2049)],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(0.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search upcoming by teacher, department, date/time, reason, remarks...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentHomeAppointments>>(
              future: widget.initialFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<StudentHomeAppointments> items = snapshot.data ?? [];
                // apply filter
                final q = _q.trim().toLowerCase();
                if (q.isNotEmpty) {
                  items = items.where((a) =>
                    a.teacherName.toLowerCase().contains(q) ||
                    a.department.toLowerCase().contains(q) ||
                    a.scheduleDate.toLowerCase().contains(q) ||
                    a.scheduleTime.toLowerCase().contains(q) ||
                    a.appointmentReason.toLowerCase().contains(q) ||
                    a.appointmentRemarks.toLowerCase().contains(q)
                  ).toList();
                }
                if (items.isEmpty) {
                  return _buildEmptyState('No upcoming appointments match your search');
                }
                // sort by start
                items.sort((a, b) => (_parseStart(a) ?? DateTime(2100)).compareTo(_parseStart(b) ?? DateTime(2100)));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Text(a.teacherName, style: const TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${a.scheduleDate} • ${a.scheduleTime}', style: TextStyle(fontFamily: 'Arimo', color: Colors.grey.shade700)),
                          if (a.appointmentReason.isNotEmpty) Text('Reason: ${a.appointmentReason}', style: TextStyle(fontFamily: 'Arimo', fontStyle: FontStyle.italic, color: Colors.grey.shade800)),
                          if (a.appointmentRemarks.isNotEmpty) Text('Remarks: ${a.appointmentRemarks}', style: const TextStyle(fontFamily: 'Arimo')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseStart(StudentHomeAppointments a) {
    try {
      DateTime date;
      try { date = DateTime.parse(a.scheduleDate); }
      catch (_) {
        try { date = DateFormat('MMMM d, y').parseStrict(a.scheduleDate); }
        catch (_) {
          final now = DateTime.now();
          final md = DateFormat('MMMM d').parseStrict(a.scheduleDate);
          date = DateTime(now.year, md.month, md.day);
        }
      }
      final startStr = a.scheduleTime.contains('-') ? a.scheduleTime.split('-')[0].trim() : a.scheduleTime.trim();
      for (final fmt in ['HH:mm:ss','HH:mm','h:mm a','hh:mm a']) {
        try { final t = DateFormat(fmt).parseStrict(startStr); return DateTime(date.year,date.month,date.day,t.hour,t.minute,t.second); } catch(_){}}
      return null;
    } catch(_) { return null; }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
