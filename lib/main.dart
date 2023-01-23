import 'package:flutter/material.dart';
import 'serverRequest.dart';

void main() {
  runApp(const Learn4GloryApp());
}

class Learn4GloryApp extends StatefulWidget {
  const Learn4GloryApp({Key? key}) : super(key: key);

  @override
  State<Learn4GloryApp> createState() => _Learn4GloryAppState();
}

class _Learn4GloryAppState extends State<Learn4GloryApp> {
  String currentPage = 'landingPage';
  String prenotaPage = 'coursePage';
  String listaPage = 'listPage';
  String userSession = 'no session';
  String manageTeacher = '';
  String manageCourseTitle = '';
  String manageDayHour = '';
  int manageBookingId = -1;
  String userEmail = '';
  String userPwd = '';
  bool userLogged = false;
  int currentIndex = 0;
  String selectedCourseTitle = '';
  int selectedCourseId = -1;
  int selectedTeacherId = -1;
  int selectedLessonId = -1;
  String selectedTeacherName = '';
  String selectedTeacherSurname = '';
  String selectedLessonWeekDay = '';
  int selectedLessonHour = -1;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController errorLoginController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    errorLoginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn4Glory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: currentPage == 'landingPage'
          ? Scaffold(
              appBar: AppBar(
                title: Image.asset(
                  'images/logo.png',
                  width: 200,
                ),
                actions: [
                  Container(
                    margin:
                        const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentPage = 'LoginPage';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('Accedi',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              body: FutureBuilder<List<LessonWrapper>>(
                future: loadAllLessons(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<List<BookedLesson>>(
                          future: loadBookedLessons(),
                          builder: (context, snapshotBookedLessons) {
                            if (snapshotBookedLessons.hasData) {
                              return Card(
                                color: isBooked(snapshot.data![index].idLesson,
                                        snapshotBookedLessons.data!)
                                    ? Colors.red
                                    : Colors.green,
                                child: ListTile(
                                  title:
                                      Text(snapshot.data![index].course.title),
                                  subtitle: Text(
                                      '${snapshot.data![index].teacher.surname} - ${snapshot.data![index].weekDay} - ${snapshot.data![index].hour}'),
                                ),
                              );
                            } else if (snapshotBookedLessons.hasError) {
                              return Text('${snapshotBookedLessons.error}');
                            }
                            return const CircularProgressIndicator();
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                },
              ),
            )
          : currentPage == 'LoginPage'
              ? Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: InkWell(
                      child: Image.asset(
                        'images/logo.png',
                        width: 200,
                      ),
                      onTap: () {
                        setState(() {
                          currentPage = 'landingPage';
                        });
                      },
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(top: 60.0),
                          child: Center(
                            child: SizedBox(
                              width: 200,
                              height: 150,
                              child: Center(
                                child: Text(
                                  "Effettua il login",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                                hintText: 'abc@gmail.com'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                          //padding: EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password',
                                hintText: 'Password'),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                          width: 250,
                        ),
                        TextField(
                          readOnly: true,
                          controller: errorLoginController,
                          decoration: const InputDecoration(
                            fillColor: Colors.transparent,
                            filled: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 15,
                              bottom: 11,
                              top: 11,
                              right: 15,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          onPressed: () {
                            String temp = '';
                            userEmail = emailController.text;
                            userPwd = passwordController.text;
                            login(userEmail, userPwd)
                                .then((value) => temp = value)
                                .whenComplete(
                                  () => {
                                    if (temp != 'no session')
                                      {
                                        setState(() {
                                          userSession = temp;
                                          userLogged = true;
                                          currentPage = 'userHomePage';
                                        })
                                      }
                                    else
                                      {
                                        userEmail = '',
                                        userPwd = '',
                                        errorLoginController.text =
                                            'Email o password errati'
                                      }
                                  },
                                );
                          },
                          child: const Text(
                            'Accedi',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        const SizedBox(
                          height: 130,
                        ),
                      ],
                    ),
                  ),
                )
              : currentPage == 'userHomePage'
                  ? Scaffold(
                      appBar: AppBar(
                        title: Image.asset(
                          'images/logo.png',
                          width: 200,
                        ),
                        actions: [
                          Row(
                            children: [
                              Text(userEmail),
                              IconButton(
                                icon: const Icon(Icons.logout),
                                onPressed: () {
                                  setState(
                                    () {
                                      logout();
                                      userLogged = false;
                                      userSession = 'no session';
                                      userEmail = '';
                                      userPwd = '';
                                      currentPage = 'landingPage';
                                    },
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                      body: currentIndex == 0
                          ? FutureBuilder<List<LessonWrapper>>(
                              future: loadAllLessons(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return FutureBuilder<List<BookedLesson>>(
                                        future: loadBookedLessons(),
                                        builder:
                                            (context, snapshotBookedLessons) {
                                          if (snapshotBookedLessons.hasData) {
                                            return Card(
                                              color: isBooked(
                                                      snapshot.data![index]
                                                          .idLesson,
                                                      snapshotBookedLessons
                                                          .data!)
                                                  ? Colors.red
                                                  : Colors.green,
                                              child: ListTile(
                                                title: Text(snapshot
                                                    .data![index].course.title),
                                                subtitle: Text(
                                                    '${snapshot.data![index].teacher.surname} - ${snapshot.data![index].weekDay} - ${snapshot.data![index].hour}'),
                                              ),
                                            );
                                          } else if (snapshotBookedLessons
                                              .hasError) {
                                            return Text(
                                                '${snapshotBookedLessons.error}');
                                          }
                                          return const CircularProgressIndicator();
                                        },
                                      );
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                return const CircularProgressIndicator();
                              },
                            )
                          : currentIndex == 1
                              ? Scaffold(
                                  body: prenotaPage == 'coursePage'
                                      ? FutureBuilder(
                                          future: loadAllCourses(),
                                          // show only course that are active
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return ListView.builder(
                                                itemCount:
                                                    snapshot.data!.length,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                    child: ListTile(
                                                      title: Text(
                                                        snapshot
                                                            .data![index].title,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          selectedCourseTitle =
                                                              snapshot
                                                                  .data![index]
                                                                  .title;
                                                          selectedCourseId =
                                                              snapshot
                                                                  .data![index]
                                                                  .idCourse;
                                                          prenotaPage =
                                                              'teacherOfCoursePage';
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text('${snapshot.error}');
                                            }
                                            return const CircularProgressIndicator();
                                          },
                                        )
                                      : prenotaPage == 'teacherOfCoursePage'
                                          ? FutureBuilder(
                                              future: loadTeacherOfCourse(
                                                  selectedCourseId),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return ListView.builder(
                                                    itemCount:
                                                        snapshot.data!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Card(
                                                        child: ListTile(
                                                          title: Text(
                                                            snapshot
                                                                .data![index]
                                                                .surname,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          onTap: () {
                                                            setState(() {
                                                              selectedTeacherSurname =
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .surname;
                                                              selectedTeacherName =
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .name;
                                                              selectedTeacherId =
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .idTeacher;
                                                              prenotaPage =
                                                                  'teacherSummaryPage';
                                                            });
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      '${snapshot.error}');
                                                }
                                                return const CircularProgressIndicator();
                                              },
                                            )
                                          : prenotaPage == 'teacherSummaryPage'
                                              ? FutureBuilder(
                                                  future:
                                                      lessonsOfTeacherCourse(
                                                          selectedTeacherId,
                                                          selectedCourseId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      return ListView.builder(
                                                        itemCount: snapshot
                                                            .data!.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Card(
                                                            child: ListTile(
                                                              title: Text(
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .weekDay,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              subtitle: Text(
                                                                '${snapshot.data![index].hour}:00',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              onTap: () {
                                                                setState(
                                                                  () {
                                                                    selectedLessonWeekDay = snapshot
                                                                        .data![
                                                                            index]
                                                                        .weekDay;
                                                                    selectedLessonHour =
                                                                        snapshot
                                                                            .data![index]
                                                                            .hour;
                                                                    selectedLessonId = snapshot
                                                                        .data![
                                                                            index]
                                                                        .idLesson;
                                                                    prenotaPage =
                                                                        'confirmBookPage';
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          '${snapshot.error}');
                                                    }
                                                    return const CircularProgressIndicator();
                                                  },
                                                )
                                              : prenotaPage == 'confirmBookPage'
                                                  ? SizedBox(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(50),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                    'Utente',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                      userEmail),
                                                                ],
                                                              )),
                                                          Container(
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(50),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                    'Corso',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                      selectedCourseTitle),
                                                                ],
                                                              )),
                                                          Container(
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(50),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                    'Docente',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                      '$selectedTeacherName $selectedTeacherSurname'),
                                                                ],
                                                              )),
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(50),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                const Text(
                                                                  'Lezione',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                    '$selectedLessonWeekDay - $selectedLessonHour:00'),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 50,
                                                                    right: 50,
                                                                    top: 30),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .black54,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                      () {
                                                                        prenotaPage =
                                                                            'teacherSummaryPage';
                                                                      },
                                                                    );
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Annulla',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .redAccent,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                      () {
                                                                        int ris =
                                                                            0;
                                                                        makeBooking(
                                                                                userEmail,
                                                                                userPwd,
                                                                                selectedLessonId)
                                                                            .then((value) =>
                                                                                ris = value)
                                                                            .whenComplete(
                                                                              () => {
                                                                                if (ris != -1)
                                                                                  {
                                                                                    currentIndex = 2,
                                                                                  }
                                                                                else
                                                                                  {
                                                                                    prenotaPage = 'bookingErrorPage',
                                                                                  }
                                                                              },
                                                                            );
                                                                      },
                                                                    );
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Prenota',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : prenotaPage ==
                                                          'bookingErrorPage'
                                                      ? Scaffold(
                                                          body: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: Center(
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    height: 250,
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 50,
                                                                        bottom:
                                                                            50,
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            10),
                                                                    child: const Text(
                                                                        "Impossibile prenotare la lezione. Hai già prenotato una lezione in questo giorno e orario.",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black54,
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                  ),
                                                                  ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .black54,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        prenotaPage =
                                                                            'teacherSummaryPage';
                                                                      });
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Torna indietro',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : prenotaPage ==
                                                              'myBookingsPage'
                                                          ? const Scaffold(
                                                              body: Text(
                                                                  "Booking page"),
                                                            )
                                                          : const Scaffold(
                                                              body: Text(
                                                                  "Error Page"),
                                                            ),
                                )
                              : listaPage == 'listPage'
                                  ? Scaffold(
                                      body: FutureBuilder(
                                        future:
                                            userLessonsList(userEmail, userPwd),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return ListView.builder(
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index) {
                                                return Card(
                                                    child: ListTile(
                                                  title: Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20,
                                                            left: 20,
                                                            right: 20,
                                                            bottom: 20),
                                                    height: 250,
                                                    child: snapshot.data![index]
                                                                .completed ||
                                                            snapshot
                                                                .data![index]
                                                                .deleted
                                                        ? Column(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            10),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      "Lezione",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    const Spacer(),
                                                                    Text(
                                                                      snapshot
                                                                          .data![
                                                                              index]
                                                                          .getLesson()
                                                                          .getCourse()
                                                                          .getTitle(),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black54),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            25),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      "Docente",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    const Spacer(),
                                                                    Text(
                                                                      "${snapshot.data![index].getLesson().getTeacher().getName()} ${snapshot.data![index].getLesson().getTeacher().getSurname()}",
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black54),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            25),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      "Data e ora",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    const Spacer(),
                                                                    Text(
                                                                      "${snapshot.data![index].getLesson().getWeekDay()} ${snapshot.data![index].getLesson().getHour()}:00",
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black54),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 25,
                                                                        bottom:
                                                                            10),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      "Stato",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    const Spacer(),
                                                                    snapshot.data![index].completed ==
                                                                            true
                                                                        ? const Text(
                                                                            "Completata",
                                                                            style:
                                                                                TextStyle(color: Colors.black54),
                                                                          )
                                                                        : snapshot.data![index].deleted ==
                                                                                true
                                                                            ? const Text(
                                                                                "Cancellata",
                                                                                style: TextStyle(color: Colors.black54),
                                                                              )
                                                                            : const Text(
                                                                                "In corso",
                                                                                style: TextStyle(color: Colors.black54),
                                                                              ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Text(
                                                                    "Lezione",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  const Spacer(),
                                                                  Text(
                                                                    snapshot
                                                                        .data![
                                                                            index]
                                                                        .getLesson()
                                                                        .getCourse()
                                                                        .getTitle(),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black54),
                                                                  ),
                                                                ],
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            15),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      "Docente",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    const Spacer(),
                                                                    Text(
                                                                      "${snapshot.data![index].getLesson().getTeacher().getName()} ${snapshot.data![index].getLesson().getTeacher().getSurname()}",
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black54),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            15),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      "Data e ora",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    const Spacer(),
                                                                    Text(
                                                                      "${snapshot.data![index].getLesson().getWeekDay()} ${snapshot.data![index].getLesson().getHour()}:00",
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black54),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 15,
                                                                        bottom:
                                                                            20),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      "Stato",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black87,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    const Spacer(),
                                                                    snapshot.data![index].completed ==
                                                                            true
                                                                        ? const Text(
                                                                            "Completata",
                                                                            style:
                                                                                TextStyle(color: Colors.black54),
                                                                          )
                                                                        : snapshot.data![index].deleted ==
                                                                                true
                                                                            ? const Text(
                                                                                "Cancellata",
                                                                                style: TextStyle(color: Colors.black54),
                                                                              )
                                                                            : const Text(
                                                                                "In corso",
                                                                                style: TextStyle(color: Colors.black54),
                                                                              ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 100,
                                                                height: 30,
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStateProperty.all(
                                                                              Colors.redAccent)),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      manageTeacher =
                                                                          "${snapshot.data![index].getLesson().getTeacher().getName()} ${snapshot.data![index].getLesson().getTeacher().getSurname()}";
                                                                      manageCourseTitle = snapshot
                                                                          .data![
                                                                              index]
                                                                          .getLesson()
                                                                          .getCourse()
                                                                          .getTitle();
                                                                      manageDayHour =
                                                                          "${snapshot.data![index].getLesson().getWeekDay()} - ${snapshot.data![index].getLesson().getHour()}:00";
                                                                      manageBookingId = snapshot
                                                                          .data![
                                                                              index]
                                                                          .idBooking;
                                                                      listaPage =
                                                                          'manageBooking';
                                                                    });
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Gestisci",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                ));
                                              },
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  : listaPage == 'manageBooking'
                                      ? Scaffold(
                                          body: SizedBox(
                                            width: double.infinity,
                                            height: double.infinity,
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 35, bottom: 50),
                                                  child: const Text(
                                                    "Gestisci prenotazione",
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30,
                                                          right: 30,
                                                          bottom: 40),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Utente",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        userEmail,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30,
                                                          right: 30,
                                                          bottom: 40),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Docente",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        manageTeacher,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30,
                                                          right: 30,
                                                          bottom: 40),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Lezione",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        manageCourseTitle,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30,
                                                          right: 30,
                                                          bottom: 40),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Data e ora",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        manageDayHour,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30,
                                                          right: 30,
                                                          bottom: 40,
                                                          top: 40),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: 120,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Colors
                                                                          .redAccent)),
                                                          onPressed: () {
                                                            setState(() {
                                                              bool result =
                                                                  false;
                                                              deleteBooking(
                                                                      userEmail,
                                                                      userPwd,
                                                                      manageBookingId)
                                                                  .then((value) =>
                                                                      result =
                                                                          value)
                                                                  .whenComplete(
                                                                      () => {
                                                                            if (result)
                                                                              {
                                                                                listaPage = 'listPage',
                                                                              }
                                                                            else
                                                                              {
                                                                                listaPage = 'errorPage',
                                                                              }
                                                                          });
                                                            });
                                                          },
                                                          child: const Text(
                                                            "Cancella",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 120,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Colors
                                                                          .green)),
                                                          onPressed: () {
                                                            setState(() {
                                                              bool result =
                                                                  false;
                                                              confirmBooking(
                                                                      userEmail,
                                                                      userPwd,
                                                                      manageBookingId)
                                                                  .then((value) =>
                                                                      result =
                                                                          value)
                                                                  .whenComplete(
                                                                      () => {
                                                                            if (result)
                                                                              {
                                                                                listaPage = 'listPage',
                                                                              }
                                                                            else
                                                                              {
                                                                                listaPage = 'errorPage',
                                                                              }
                                                                          });
                                                            });
                                                          },
                                                          child: const Text(
                                                            "Conferma",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      : const Scaffold(
                                          body: SizedBox(
                                            width: double.infinity,
                                            height: 300,
                                            child: Text(
                                                'Spiacenti si è verificato un errore'),
                                          ),
                                        ),
                      bottomNavigationBar: BottomNavigationBar(
                        selectedItemColor: Colors.redAccent,
                        items: const [
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home), label: 'Home'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.search), label: 'Prenota'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.book),
                              label: 'Lista prenotazioni'),
                        ],
                        currentIndex: currentIndex,
                        onTap: (int index) {
                          setState(() {
                            currentIndex = index;
                            prenotaPage = 'coursePage';
                            listaPage = 'listPage';
                          });
                        },
                      ),
                    )
                  : const Scaffold(
                      body: Text('Error'),
                    ),
    );
  }
}

bool isBooked(int idLesson, List<BookedLesson> bookedLessons) {
  for (var bookedLesson in bookedLessons) {
    if (bookedLesson.lesson == idLesson) {
      return true;
    }
  }
  return false;
}
