class ApiConstants {
  static const String baseUrl = 'http://192.168.18.23:8000/api';

  // Auth
  static const String login          = '/login';
  static const String logout         = '/logout';
  static const String me             = '/me';
  static const String changePassword = '/change-password';

  // Parent (acceso por código de estudiante)
  static const String parentLookup    = '/parent/lookup';
  static const String parentChild     = '/parent/child';
  static const String parentGrades    = '/parent/grades';
  static const String parentFees      = '/parent/fees';
  static const String parentConduct   = '/parent/conduct';
  static const String parentTasks     = '/parent/tasks';
  static const String parentAttendance = '/parent/attendance';

  // Me (estudiante autenticado)
  static const String meStudent    = '/me/student';
  static const String meSchedule   = '/me/schedule';
  static const String meAttendance = '/me/attendance/report';
  static const String meFees       = '/me/fees';
  static const String meTasks      = '/me/tasks';
  static const String meSubjects   = '/me/subjects';

  // Docente
  static const String teacherMe       = '/teachers/me';
  static const String teacherSections = '/teachers/me/sections';
  static const String teacherHomeworks = '/teacher/homeworks';

  // Admin
  static const String students  = '/students';
  static const String teachers  = '/teachers';
  static const String sections  = '/sections';
  static const String periods   = '/periods';
  static const String conduct   = '/conduct';
}
