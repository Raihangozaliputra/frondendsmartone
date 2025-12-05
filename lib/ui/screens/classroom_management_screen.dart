import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/data/services/user_management_service.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class ClassroomManagementScreen extends StatefulWidget {
  const ClassroomManagementScreen({super.key});

  @override
  State<ClassroomManagementScreen> createState() =>
      _ClassroomManagementScreenState();
}

class _ClassroomManagementScreenState extends State<ClassroomManagementScreen> {
  List<Map<String, dynamic>> _classrooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classrooms = await UserManagementService().getAllClassrooms();
      setState(() {
        _classrooms = classrooms;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteClassroom(String classroomId) async {
    try {
      await UserManagementService().deleteClassroom(classroomId);
      // Refresh the list
      _loadClassrooms();

      if (mounted) {
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.translate('classroom_deleted_successfully'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${languageProvider.translate('failed')} ${languageProvider.translate('delete_classroom').toLowerCase()}: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(String classroomId, String classroomName) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('confirm_delete')),
          content: Text(
            '${languageProvider.translate('sure_delete_classroom')} $classroomName?',
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
                Navigator.of(context).pop();
                _deleteClassroom(classroomId);
              },
              child: Text(languageProvider.translate('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('classroom_management')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadClassrooms,
                    child: Text(languageProvider.translate('retry')),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: languageProvider.translate(
                        'search_classrooms',
                      ),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: _classrooms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.class_,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  languageProvider.translate(
                                    'no_classrooms_found',
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _classrooms.length,
                            itemBuilder: (context, index) {
                              final classroom = _classrooms[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(Icons.class_),
                                  ),
                                  title: Text(classroom['name'] ?? ''),
                                  subtitle: Text(
                                    classroom['description'] ?? '',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          // Implement edit functionality
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                            classroom['id'].toString(),
                                            classroom['name'].toString(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add classroom functionality
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
