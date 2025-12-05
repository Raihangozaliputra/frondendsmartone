import 'package:smartone/data/models/user.dart';

abstract class StudentRepository {
  Future<List<User>> getAllStudents();
  Future<User?> getStudentById(String id);
  Future<User> createStudent(User student);
  Future<User> updateStudent(User student);
  Future<void> deleteStudent(String id);
  Future<List<User>> searchStudents(String query);
}
