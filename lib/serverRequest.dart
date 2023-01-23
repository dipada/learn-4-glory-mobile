import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> login(String userEmail, String userPwd) async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletSession');

  var response = await http.post(url,
      body: {'action': 'login', 'userEmail': userEmail, 'userPwd': userPwd});

  return jsonDecode(response.body);
}

Future<void> logout() async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletSession');
  url = url.replace(queryParameters: {'action': 'logout'});
  http.get(url);
}

Future<List<Course>> loadAllCourses() async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');
  url = url.replace(queryParameters: {'action': 'allCourse'});

  var response = await http.get(url);
  List<Course> courses = [];

  for (var course in jsonDecode(response.body)) {
    courses.add(Course(
        idCourse: course['id_course'],
        title: course['title'],
        active: course['active']));
  }

  return courses;
}

Future<List<Teacher>> loadTeacherOfCourse(int idCourse) async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');
  url = url.replace(queryParameters: {
    'action': 'teachersOfCourse',
    'course_id': idCourse.toString()
  });

  var response = await http.get(url);

  List<Teacher> teachers = [];

  for (var teacher in jsonDecode(response.body)) {
    teachers.add(Teacher(
        idTeacher: teacher['id_teacher'],
        name: teacher['name'],
        surname: teacher['surname'],
        active: teacher['active']));
  }

  return teachers;
}

Future<List<LessonWrapper>> lessonsOfTeacherCourse(
    int teacherid, int courseid) async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');
  url = url.replace(queryParameters: {
    'action': 'lessonsOfTeacherCourseNotBooked',
    'teacherid': teacherid.toString(),
    'courseid': courseid.toString()
  });

  var response = await http.get(url);

  List<LessonWrapper> lessons = [];

  for (var lesson in jsonDecode(response.body)) {
    lessons.add(LessonWrapper(
        idLesson: lesson['id_lesson'],
        course: Course(
            idCourse: lesson['course']['id_course'],
            title: lesson['course']['title'],
            active: lesson['course']['active']),
        teacher: Teacher(
            idTeacher: lesson['teacher']['id_teacher'],
            name: lesson['teacher']['name'],
            surname: lesson['teacher']['surname'],
            active: lesson['teacher']['active']),
        weekDay: lesson['week_day'],
        hour: lesson['hour'],
        active: lesson['active']));
  }

  return lessons;
}

Future<int> makeBooking(String userEmail, String userPwd, int lessonId) async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');

  var response = await http.post(url, body: {
    'action': 'insertBookingEmail',
    'userEmail': userEmail,
    'userPwd': userPwd,
    'lessonid': lessonId.toString()
  });

  return jsonDecode(response.body);
}

Future<bool> confirmBooking(
    String userEmail, String userPwd, int bookingId) async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');

  var response = await http.post(url, body: {
    'action': 'confirmBookingEmail',
    'userEmail': userEmail,
    'userPwd': userPwd,
    'bookingId': bookingId.toString()
  });

  return jsonDecode(response.body);
}

Future<bool> deleteBooking(
    String userEmail, String userPwd, int bookingId) async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');

  var response = await http.post(url, body: {
    'action': 'deleteBookingEmail',
    'userEmail': userEmail,
    'userPwd': userPwd,
    'bookingId': bookingId.toString()
  });

  return jsonDecode(response.body);
}

Future<List<BookedLessonWrapper>> userLessonsList(
    String userEmail, String userPwd) async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');

  var response = await http.post(url, body: {
    'action': 'userBookingsEmail',
    'userEmail': userEmail,
    'userPwd': userPwd
  });

  List<BookedLessonWrapper> lessons = [];
  /*
final int idBooking;
  final User user;
  final LessonWrapper lesson;
  final String weekDay;
  final int hour;
  final bool completed;
  final bool deleted;
 */

  for (var bookedLessonWrap in jsonDecode(response.body)) {
    lessons.add(BookedLessonWrapper(
      idBooking: bookedLessonWrap['id_booking'],
      user: User(
        idUser: bookedLessonWrap['user']['id_user'],
        username: bookedLessonWrap['user']['username'],
        password: bookedLessonWrap['user']['password'],
        email: bookedLessonWrap['user']['email'],
        admin: bookedLessonWrap['user']['admin'],
        active: bookedLessonWrap['user']['active'],
      ),
      lesson: LessonWrapper(
        idLesson: bookedLessonWrap['lesson']['id_lesson'],
        course: Course(
          idCourse: bookedLessonWrap['lesson']['course']['id_course'],
          title: bookedLessonWrap['lesson']['course']['title'],
          active: bookedLessonWrap['lesson']['course']['active'],
        ),
        teacher: Teacher(
          idTeacher: bookedLessonWrap['lesson']['teacher']['id_teacher'],
          surname: bookedLessonWrap['lesson']['teacher']['surname'],
          name: bookedLessonWrap['lesson']['teacher']['name'],
          active: bookedLessonWrap['lesson']['teacher']['active'],
        ),
        weekDay: bookedLessonWrap['lesson']['week_day'],
        hour: bookedLessonWrap['lesson']['hour'],
        active: bookedLessonWrap['lesson']['active'],
      ),
      weekDay: bookedLessonWrap['week_day'],
      hour: bookedLessonWrap['hour'],
      completed: bookedLessonWrap['completed'],
      deleted: bookedLessonWrap['deleted'],
    ));
  }

  return lessons;
}

Future<List<LessonWrapper>> loadAllLessons() async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');
  url = url.replace(queryParameters: {'action': 'lessons'});
  var response = await http.get(url);
  List<LessonWrapper> lessons = [];

  // convert the response body to a list of LessonWrapper
  for (var lesson in jsonDecode(response.body)) {
    lessons.add(LessonWrapper(
        idLesson: lesson['id_lesson'],
        course: Course(
            idCourse: lesson['course']['id_course'],
            title: lesson['course']['title'],
            active: lesson['course']['active']),
        teacher: Teacher(
            idTeacher: lesson['teacher']['id_teacher'],
            name: lesson['teacher']['name'],
            surname: lesson['teacher']['surname'],
            active: lesson['teacher']['active']),
        weekDay: lesson['week_day'],
        hour: lesson['hour'],
        active: lesson['active']));
  }

  return lessons;
}

Future<List<BookedLesson>> loadBookedLessons() async {
  Uri url = Uri.parse(
      'http://192.168.1.243:8081/learn4glory_war_exploded/ServletDao');
  url = url.replace(queryParameters: {'action': 'allBookedLesson'});
  var response = await http.get(url);
  List<BookedLesson> bookedLessons = [];

  for (var bookedLesson in jsonDecode(response.body)) {
    bookedLessons.add(BookedLesson(
        idBooking: bookedLesson['id_booking'],
        user: bookedLesson['user'],
        lesson: bookedLesson['lesson'],
        weekDay: bookedLesson['week_day'],
        hour: bookedLesson['hour'],
        completed: bookedLesson['completed'],
        deleted: bookedLesson['deleted']));
  }

  return bookedLessons;
}

class BookedLesson {
  final int idBooking;
  final int user;
  final int lesson;
  final String weekDay;
  final int hour;
  final bool completed;
  final bool deleted;

  BookedLesson(
      {required this.idBooking,
      required this.user,
      required this.lesson,
      required this.weekDay,
      required this.hour,
      required this.completed,
      required this.deleted});
}

class BookedLessonWrapper {
  final int idBooking;
  final User user;
  final LessonWrapper lesson;
  final String weekDay;
  final int hour;
  final bool completed;
  final bool deleted;

  BookedLessonWrapper(
      {required this.idBooking,
      required this.user,
      required this.lesson,
      required this.weekDay,
      required this.hour,
      required this.completed,
      required this.deleted});

  // getters for the fields
  int getIdBooking() => idBooking;

  User getUser() => user;

  LessonWrapper getLesson() => lesson;

  String getWeekDay() => weekDay;

  int getHour() => hour;

  bool getCompleted() => completed;

  bool getDeleted() => deleted;
}

class User {
  final int idUser;
  final String username;
  final String password;
  final String email;
  final bool admin;
  final bool active;

  User(
      {required this.idUser,
      required this.username,
      required this.password,
      required this.email,
      required this.admin,
      required this.active});

  int getIdUser() => idUser;

  String getUsername() => username;

  String getPassword() => password;

  String getEmail() => email;

  bool getAdmin() => admin;

  bool getActive() => active;
}

class LessonWrapper {
  final int idLesson;
  final Course course;
  final Teacher teacher;
  final String weekDay;
  final int hour;
  final bool active;

  LessonWrapper(
      {required this.idLesson,
      required this.course,
      required this.teacher,
      required this.weekDay,
      required this.hour,
      required this.active});

  int getIdLesson() => idLesson;

  Course getCourse() => course;

  Teacher getTeacher() => teacher;

  String getWeekDay() => weekDay;

  int getHour() => hour;

  bool getActive() => active;
}

class Teacher {
  final int idTeacher;
  final String name;
  final String surname;
  final bool active;

  Teacher(
      {required this.idTeacher,
      required this.name,
      required this.surname,
      required this.active});

  int getIdTeacher() => idTeacher;

  String getName() => name;

  String getSurname() => surname;

  bool getActive() => active;
}

class Course {
  final int idCourse;
  final String title;
  final bool active;

  Course({required this.idCourse, required this.title, required this.active});

  int getIdCourse() => idCourse;

  String getTitle() => title;

  bool getActive() => active;
}
