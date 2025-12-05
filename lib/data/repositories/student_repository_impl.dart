import 'package:smartone/data/models/user.dart';
import 'package:smartone/utils/local_database.dart';
import 'package:smartone/data/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  @override
  Future<List<User>> getAllStudents() async {
    final allUsers = LocalDatabase().getAllUsers();
    return allUsers.where((user) => user.role == 'student').toList();
  }

  @override
  Future<User?> getStudentById(String id) async {
    final user = LocalDatabase().getUser(id);
    return user != null && user.role == 'student' ? user : null;
  }

  @override
  Future<User> createStudent(User student) async {
    // Ensure the user has the student role
    final studentUser = student.copyWith(role: 'student');
    await LocalDatabase().saveUser(studentUser);
    return studentUser;
  }

  @override
  Future<User> updateStudent(User student) async {
    // Ensure the user has the student role
    final studentUser = student.copyWith(role: 'student');
    await LocalDatabase().saveUser(studentUser);
    return studentUser;
  }

  @override
  Future<void> deleteStudent(String id) async {
    await LocalDatabase().deleteUser(id);
  }

  @override
  Future<List<User>> searchStudents(String query) async {
    final allStudents = await getAllStudents();
    final lowercaseQuery = query.toLowerCase();

    return allStudents.where((student) {
      return student.name.toLowerCase().contains(lowercaseQuery) ||
          student.email.toLowerCase().contains(lowercaseQuery) ||
          student.id.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
