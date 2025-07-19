import 'package:flutter/material.dart';
import 'package:nutify/pages/teacherHome.dart';
import 'package:nutify/pages/teacherInbox.dart';
import 'package:nutify/pages/teacherProfile.dart';
import 'package:nutify/models/teacherSchedule.dart';

class TeacherEditSched extends StatefulWidget {
  TeacherEditSched({super.key});

  @override
  _TeacherEditSchedState createState() => _TeacherEditSchedState();
}

class _TeacherEditSchedState extends State<TeacherEditSched>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Monday to Saturday
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildTeacherAppBar(context),
      body: Column(
        children: [
          _buildNavigationalTabs(),
          _buildTabViews(),
        ],
      ),
    );
  }

  Widget _buildNavigationalTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Color(0xFFFFD418),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFFFFD418),
        indicatorWeight: 3,
        isScrollable: false, // Changed to false to span full width
        labelStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          Tab(text: 'Mon'),
          Tab(text: 'Tues'),
          Tab(text: 'Wed'),
          Tab(text: 'Thurs'),
          Tab(text: 'Fri'),
          Tab(text: 'Sat'),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDaySchedules('Monday'),
          _buildDaySchedules('Tuesday'),
          _buildDaySchedules('Wednesday'),
          _buildDaySchedules('Thursday'),
          _buildDaySchedules('Friday'),
          _buildDaySchedules('Saturday'),
        ],
      ),
    );
  }

  Widget _buildDaySchedules(String dayOfWeek) {
    return FutureBuilder<List<TeacherSchedule>>(
      future: TeacherSchedule.getTeacherSchedulesByDay(dayOfWeek),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<TeacherSchedule> schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return _buildEmptyState('No schedules set for $dayOfWeek');
        }

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: schedules.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            var schedule = schedules[index];
            return _buildScheduleCard(
              schedule.startTime12h,  // Use 12-hour format for display
              schedule.endTime12h,    // Use 12-hour format for display
              schedule.status,
              schedule.scheduleId,
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleCard(
    String startTime,
    String endTime,
    String status,
    String scheduleId,
  ) {
    // Get status-specific colors and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'available':
        statusColor = Color(0xFF4CAF50); // Green
        statusIcon = Icons.check_circle;
        statusText = 'Available';
        break;
      case 'booked':
        statusColor = Color(0xFFF44336); // Red
        statusIcon = Icons.event_busy;
        statusText = 'Booked';
        break;
      default:
        statusColor = Color(0xFF9E9E9E); // Grey
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Color(0xFF35408E).withOpacity(0.05),
              Color(0xFF1A2049).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Time display section
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF35408E),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons section
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD418).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showEditScheduleDialog(scheduleId, startTime, endTime);
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFFFD418),
                        size: 20,
                      ),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Delete button
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showDeleteScheduleDialog(scheduleId, startTime, endTime);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Color(0xFFF44336),
                        size: 20,
                      ),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddScheduleDialog();
            },
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Schedule',
              style: TextStyle(
                fontFamily: 'Arimo',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF35408E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showAddScheduleDialog() {
    String? selectedDay;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 3,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Add New Schedule',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF35408E),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Day Dropdown
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDay,
                          hint: Text(
                            'Select Day',
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                          isExpanded: true,
                          items: [
                            'Monday',
                            'Tuesday', 
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday'
                          ].map((String day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontFamily: 'Arimo',
                                  color: Color(0xFF35408E),
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDay = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Start Time Field
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFF35408E),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Color(0xFF35408E),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setState(() {
                            startTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          startTime != null 
                              ? startTime!.format(context)
                              : 'Start time',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            color: startTime != null 
                                ? Color(0xFF35408E) 
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // "to" text
                    Text(
                      'to',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // End Time Field
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFF35408E),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Color(0xFF35408E),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setState(() {
                            endTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          endTime != null 
                              ? endTime!.format(context)
                              : 'End time',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            color: endTime != null 
                                ? Color(0xFF35408E) 
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        
                        // Add Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (selectedDay != null && startTime != null && endTime != null)
                                ? () {
                                    // TODO: Implement add schedule functionality
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Schedule will be added: $selectedDay ${startTime!.format(context)} - ${endTime!.format(context)}',
                                          style: TextStyle(fontFamily: 'Arimo'),
                                        ),
                                        backgroundColor: Color(0xFF35408E),
                                      ),
                                    );
                                  }
                                : null,
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD418),
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditScheduleDialog(String scheduleId, String startTime, String endTime) {
    print('Edit schedule dialog for ID: $scheduleId');
    // TODO: Implement edit schedule dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit schedule feature coming soon',
          style: TextStyle(fontFamily: 'Arimo'),
        ),
        backgroundColor: Color(0xFFFFD418),
      ),
    );
  }

  void _showDeleteScheduleDialog(String scheduleId, String startTime, String endTime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 3,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delete Icon with gradient background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF44336).withOpacity(0.1),
                        Color(0xFFE53935).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFF44336),
                    size: 30,
                  ),
                ),
                SizedBox(height: 20),
                // Title
                Text(
                  'Delete Schedule',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 10),
                // Content
                Text(
                  'Are you sure you want to delete the schedule from $startTime to $endTime?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 25),
                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade300,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.grey.shade700,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Delete Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF44336), Color(0xFFE53935)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFF44336).withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // Close dialog
                            
                            // Show loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Deleting schedule...',
                                  style: TextStyle(fontFamily: 'Arimo'),
                                ),
                                backgroundColor: Color(0xFF35408E),
                              ),
                            );
                            
                            // Call delete API
                            bool success = await TeacherSchedule.deleteSchedule(scheduleId);
                            
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Schedule deleted successfully',
                                    style: TextStyle(fontFamily: 'Arimo'),
                                  ),
                                  backgroundColor: Color(0xFF4CAF50),
                                ),
                              );
                              // Refresh the page
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete schedule',
                                    style: TextStyle(fontFamily: 'Arimo'),
                                  ),
                                  backgroundColor: Color(0xFFF44336),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Delete'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildTeacherAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80, // Increased height for better spacing
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherProfile(),
                settings: RouteSettings(name: '/teacherProfile'),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      title: Container(
        margin: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0),
        child: const Text(
          'Edit Schedules',
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
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      actions: [
        // Add schedule button (moved to replace profile button position)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Container(
            margin: const EdgeInsets.only(right: 25.0),
            decoration: BoxDecoration(
              color: Color(0xFFFFD418),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                _showAddScheduleDialog();
              },
              icon: Icon(
                Icons.add,
                color: Color(0xFF35408E),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}