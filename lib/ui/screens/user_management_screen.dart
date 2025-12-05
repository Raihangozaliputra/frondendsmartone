import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/data/services/user_management_service.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await UserManagementService().getAllUsers();
      setState(() {
        _users = users;
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

  Future<void> _deleteUser(String userId) async {
    try {
      await UserManagementService().deleteUser(userId);
      // Refresh the list
      _loadUsers();

      if (mounted) {
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.translate('user_deleted_successfully'),
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
              '${languageProvider.translate('failed')} ${languageProvider.translate('delete_user').toLowerCase()}: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(String userId, String userName) {
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
            '${languageProvider.translate('sure_delete_user')} $userName?',
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
                _deleteUser(userId);
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
        title: Text(languageProvider.translate('user_management')),
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
                    onPressed: _loadUsers,
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
                      labelText: languageProvider.translate('search_users'),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: _users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  languageProvider.translate('no_users_found'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(_getRoleIcon(user.role)),
                                  ),
                                  title: Text(user.name),
                                  subtitle: Text(
                                    '${languageProvider.translate('role')}: ${user.role}',
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
                                            user.id,
                                            user.name,
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
          // Implement add user functionality
        },
        child: Icon(Icons.add),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'teacher':
        return Icons.school;
      case 'student':
        return Icons.person;
      default:
        return Icons.person;
    }
  }
}
