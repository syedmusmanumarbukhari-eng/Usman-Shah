import 'package:flutter/material.dart';

void main() {
  runApp(const StudentCampusApp());
}

class StudentCampusApp extends StatelessWidget {
  const StudentCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital ID & Campus Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deep Royal Navy
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF0D9488), // Teal accent
          surface: const Color(0xFFF8FAFC),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
      ),
      home: const CampusDashboardPage(),
    );
  }
}

class CourseItem {
  final String code;
  final String title;
  final String instructor;
  final String schedule;
  final int credits;
  final IconData icon;
  final Color color;

  CourseItem({
    required this.code,
    required this.title,
    required this.instructor,
    required this.schedule,
    required this.credits,
    required this.icon,
    required this.color,
  });
}

class CampusDashboardPage extends StatefulWidget {
  const CampusDashboardPage({super.key});

  @override
  State<CampusDashboardPage> createState() => _CampusDashboardPageState();
}

class _CampusDashboardPageState extends State<CampusDashboardPage> {
  // Student Information Data
  final String studentName = "Syed Muhammad Ali";
  final String rollNumber = "CS-2022-089";
  final String department = "Computer Science";
  final String semester = "6th Semester (BS-CS)";
  final String batch = "2022 - 2026";
  final String studentEmail = "ali.shah@university.edu.pk";
  final bool isOnline = true;

  // Search state
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Quick Notes state
  final TextEditingController _noteController = TextEditingController();
  final List<String> _quickNotes = [
    "Prepare MAD Lab Assignment 3 by Friday.",
    "Database Quiz scheduled for next Tuesday.",
    "Return 'Clean Code' book to Campus Library."
  ];

  // Course List Data
  final List<CourseItem> _allCourses = [
    CourseItem(
      code: "CS-301",
      title: "Mobile Application Development",
      instructor: "Prof. Ahmed Raza",
      schedule: "Mon, Wed (10:00 AM - 11:30 AM)",
      credits: 3,
      icon: Icons.phone_android,
      color: Colors.indigo,
    ),
    CourseItem(
      code: "CS-305",
      title: "Database Management Systems",
      instructor: "Dr. Sara Khan",
      schedule: "Tue, Thu (09:00 AM - 10:30 AM)",
      credits: 4,
      icon: Icons.storage,
      color: Colors.teal,
    ),
    CourseItem(
      code: "CS-309",
      title: "Software Engineering Practices",
      instructor: "Prof. Usman Tariq",
      schedule: "Mon, Fri (01:30 PM - 03:00 PM)",
      credits: 3,
      icon: Icons.account_tree,
      color: Colors.deepOrange,
    ),
    CourseItem(
      code: "CS-312",
      title: "Artificial Intelligence & ML",
      instructor: "Dr. Bilal Hassan",
      schedule: "Wed, Fri (11:30 AM - 01:00 PM)",
      credits: 3,
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    CourseItem(
      code: "CS-315",
      title: "Computer Networks & Security",
      instructor: "Engr. Fatima Noor",
      schedule: "Tue, Thu (02:00 PM - 03:30 PM)",
      credits: 3,
      icon: Icons.wifi_lock,
      color: Colors.blue,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addQuickNote() {
    final text = _noteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _quickNotes.insert(0, text);
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Quick note added successfully!"),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _deleteQuickNote(int index) {
    setState(() {
      _quickNotes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Note removed"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.search, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text("Search Campus Courses"),
            ],
          ),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter course title or code...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = "";
                        });
                        Navigator.pop(context);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = "";
                });
                Navigator.pop(context);
              },
              child: const Text("Reset"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text("Filter"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _allCourses.where((course) {
      if (_searchQuery.isEmpty) return true;
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      // 1. HEADER & NAVIGATION - AppBar
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Campus Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Digital Student ID Portal",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Search Courses",
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            tooltip: "Notifications",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No new campus notifications"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // 1. HEADER & NAVIGATION - Drawer Widget
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                studentName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(studentEmail),
              currentAccountPicture: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 33,
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 42,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined, color: Color(0xFF1E3A8A)),
              title: const Text("Digital ID Card"),
              selected: true,
              selectedTileColor: Colors.indigo.shade50,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_outlined, color: Color(0xFF1E3A8A)),
              title: const Text("Enrolled Courses"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined, color: Color(0xFF1E3A8A)),
              title: const Text("Academic Schedule"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_library_outlined, color: Color(0xFF1E3A8A)),
              title: const Text("Campus Library"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined, color: Color(0xFF1E3A8A)),
              title: const Text("Attendance & Grades"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.grey),
              title: const Text("Account Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------------------
            // 2 & 3. PROFILE, ID CARD & STUDENT INFO (Card, Container, Stack, Column, Row)
            // -------------------------------------------------------------
            _buildStudentDigitalIDCard(),

            const SizedBox(height: 24),

            // Section Header: Enrolled Courses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.collections_bookmark_rounded,
                        color: Color(0xFF1E3A8A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Enrolled Courses",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${filteredCourses.length} Subjects",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Showing results for \"$_searchQuery\"",
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchQuery = "";
                        _searchController.clear();
                      });
                    },
                    child: const Text(
                      "Clear filter",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // -------------------------------------------------------------
            // 4. COURSES / SUBJECTS LIST (ListView.builder & ListTile)
            // -------------------------------------------------------------
            _buildCoursesList(filteredCourses),

            const SizedBox(height: 24),

            // -------------------------------------------------------------
            // 5. QUICK NOTES / SEARCH INPUT (TextField & ElevatedButton)
            // -------------------------------------------------------------
            _buildQuickNotesSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget for Student ID Card (Card, Container, Stack, CircleAvatar, Column, Row)
  Widget _buildStudentDigitalIDCard() {
    return Card(
      elevation: 6,
      shadowColor: const Color(0xFF1E3A8A).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F172A), // Slate Dark
              Color(0xFF1E3A8A), // Royal Navy
              Color(0xFF2563EB), // Blue Accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Name Header & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.school,
                      color: Colors.amber,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "METROPOLITAN UNIVERSITY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          "STUDENT DIGITAL ID CARD",
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "VERIFIED",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Colors.white24, height: 1),
            ),

            // Profile Picture & Student Details Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. PROFILE PICTURE with Green Active/Online Dot Overlay (Stack & CircleAvatar)
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 37,
                          backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Green Active/Online Dot Overlay
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // 3. STUDENT INFO & ALIGNMENT (Column & Row)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      _buildInfoLabelValue(
                        icon: Icons.pin_outlined,
                        label: "Roll No:",
                        value: rollNumber,
                      ),
                      const SizedBox(height: 4),

                      _buildInfoLabelValue(
                        icon: Icons.domain_outlined,
                        label: "Dept:",
                        value: department,
                      ),
                      const SizedBox(height: 4),

                      _buildInfoLabelValue(
                        icon: Icons.school_outlined,
                        label: "Semester:",
                        value: semester,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional Details Row (Batch, Expiry, RFID Indicator)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniDetailColumn("Session", batch),
                  Container(height: 20, width: 1, color: Colors.white24),
                  _buildMiniDetailColumn("Valid Until", "12 / 2026"),
                  Container(height: 20, width: 1, color: Colors.white24),
                  Row(
                    children: const [
                      Icon(Icons.nfc, color: Colors.amberAccent, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "RFID Enabled",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Barcode Graphic Representation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    24,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 3),
                      width: (index % 3 == 0) ? 4 : 2,
                      height: 22,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Text(
                  "ID: $rollNumber",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLabelValue({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.amberAccent, size: 14),
        const SizedBox(width: 4),
        Text(
          "$label ",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 4. COURSES / SUBJECTS LIST (ListView.builder & ListTile)
  Widget _buildCoursesList(List<CourseItem> courses) {
    if (courses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: const [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "No courses found matching search query.",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: course.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  course.icon,
                  color: course.color,
                  size: 26,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: course.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course.code,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: course.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          course.instructor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          course.schedule,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${course.credits} Cr",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Selected Course: ${course.code} - ${course.title}"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 5. QUICK NOTES / SEARCH INPUT (TextField & ElevatedButton)
  Widget _buildQuickNotesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.note_alt_outlined,
                  color: Colors.amber.shade900,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Campus Quick Notes & Tasks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // TextField for User Input
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: "Enter a quick note or task (e.g. Exam on Monday)...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF1E3A8A)),
              suffixIcon: _noteController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _noteController.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
              ),
            ),
            onChanged: (val) {
              setState(() {});
            },
            onSubmitted: (_) => _addQuickNote(),
          ),

          const SizedBox(height: 12),

          // Submit ElevatedButton
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _addQuickNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                "Add Quick Note",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (_quickNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Saved Notes:",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Display Saved Quick Notes Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_quickNotes.length, (index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_box_outlined,
                        size: 14,
                        color: Color(0xFF1E3A8A),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _quickNotes[index],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _deleteQuickNote(index),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
