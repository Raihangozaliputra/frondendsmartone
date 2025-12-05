import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/presentation/widgets/student_list_tile.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/repositories/student_repository_impl.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final StudentRepositoryImpl _studentRepository = StudentRepositoryImpl();
  List<User> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<User> students;
      if (_searchQuery.isEmpty) {
        students = await _studentRepository.getAllStudents();
      } else {
        students = await _studentRepository.searchStudents(_searchQuery);
      }

      setState(() {
        _students = students;
      });
    } catch (e) {
      print('Error loading students: $e');
      // Show error message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query;
      _loadStudents(); // Reload with filtered results
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('student_management')),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle add student
              _showAddStudentDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: languageProvider.translate('search_students'),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: _filterStudents,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 60, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          _searchQuery.isEmpty
                              ? languageProvider.translate('no_students_found')
                              : languageProvider.translate(
                                  'no_students_match_search',
                                ),
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _loadStudents();
                              });
                            },
                            child: Text(
                              languageProvider.translate('clear_search'),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return StudentListTile(
                        name: student.name,
                        studentId: student.id,
                        profileImageUrl: student.profileImageUrl,
                        status: 'present', // Default status
                        onViewDetails: () {
                          // Navigate to student details
                          Navigator.pushNamed(
                            context,
                            '/student_details',
                            arguments: {
                              'name': student.name,
                              'studentId': student.id,
                              'email': student.email,
                              'profileImageUrl': student.profileImageUrl ?? '',
                              'className': 'Class 10A',
                              'attendanceRate': 85,
                              'totalClasses': 20,
                              'attendedClasses': 17,
                            },
                          );
                        },
                        onMarkAbsent: () {
                          // Handle mark absent
                          _showMarkAbsentDialog(student);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(languageProvider.translate('add_student')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('name'),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('email'),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  // Create new student
                  final student = User(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    email: emailController.text,
                    role: 'student',
                  );

                  // Save through repository
                  await _studentRepository.createStudent(student);

                  // Refresh student list
                  _loadStudents();

                  Navigator.of(context).pop();
                }
              },
              child: Text(languageProvider.translate('add')),
            ),
          ],
        );
      },
    );
  }

  void _showMarkAbsentDialog(User student) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(languageProvider.translate('mark_absent')),
          content: Text(
            '${languageProvider.translate('sure_mark_absent')} ${student.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                // In a real app, you would update the attendance record
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${student.name} ${languageProvider.translate('marked_as_absent')}',
                    ),
                  ),
                );
              },
              child: Text(languageProvider.translate('mark_absent')),
            ),
          ],
        );
      },
    );
  }
}
