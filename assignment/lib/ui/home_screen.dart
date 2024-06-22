import 'package:assignment/main.dart';
import 'package:assignment/ui/edittask.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'login.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
    });
    scheduleNotificationsForDueTasks();
    checkDueTasksPeriodically();
  }

  void checkDueTasksPeriodically() {
    // Check tasks periodically (e.g., every hour)
    Duration interval = Duration(minutes: 60);
    Timer.periodic(interval, (Timer t) => scheduleNotificationsForDueTasks());
  }

  void scheduleNotificationsForDueTasks() async {
    final QuerySnapshot snapshot = await _firestore.collection('tasks').get();

    for (var document in snapshot.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      if (data['dateTime'] != null) {
        // Konversi string dateTime ke objek DateTime
        DateTime dueDate = DateTime.parse(data['dateTime']);

        if (dueDate.isBefore(DateTime.now())) {
          await showNotification(data['title']);
        } else {
          await scheduleNotification(data['title'], dueDate);
        }
      }
    }
  }

  Future<void> showNotification(String title) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Task Due',
      '$title is overdue!',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> scheduleNotification(String title, DateTime dueDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Due',
      '$title is due now!',
      tz.TZDateTime.from(dueDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3639),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 36, 39),
        automaticallyImplyLeading: false,
        title: const Text(
          'Tasks',
          style: TextStyle(
            color: Color(0xFFDCD7C9),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: const Color(0xFFDCD7C9),
            onPressed: () async {
              FirebaseAuth.instance
                  .signOut()
                  .then((value) => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      ));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFA27B5C),
        foregroundColor: const Color.fromARGB(255, 30, 36, 39),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('tasks').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> activeTasks = [];
          List<DocumentSnapshot> completedTasks = [];

          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            if (data['completed'] == true) {
              completedTasks.add(document);
            } else {
              activeTasks.add(document);
            }
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                const Text(
                  'Incomplete',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFFDCD7C9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                ...activeTasks
                    .map((document) => buildTaskCard(document, false)),
                const SizedBox(height: 20.0),
                const Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFFDCD7C9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                ...completedTasks
                    .map((document) => buildTaskCard(document, true)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTaskCard(DocumentSnapshot document, bool isCompleted) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    final DateTime? dateTime =
        data['dateTime'] != null ? DateTime.tryParse(data['dateTime']) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        height: 170.0,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: isCompleted
              ? const Color(0xFFA27B5C)
              : const Color(0xFFDCD7C9), // Change color for incomplete tasks
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['title'],
                              maxLines: 1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.0,
                                  color: Colors.black)),
                          if (dateTime != null)
                            Text(
                              'Due: ${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: isCompleted
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditTaskScreen(taskDocument: document),
                            ),
                          );
                        } else if (value == 'delete') {
                          // Delete action
                          String documentId = document.id;
                          _firestore
                              .collection('tasks')
                              .doc(documentId)
                              .delete();
                        } else if (value == 'toggleComplete') {
                          // Toggle complete action
                          bool isCompleted = data['completed'] ?? false;
                          _firestore
                              .collection('tasks')
                              .doc(document.id)
                              .update({
                            'completed': !isCompleted,
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                        PopupMenuItem<String>(
                          value: 'toggleComplete',
                          child: Text(data['completed'] == true
                              ? 'Mark as Incomplete'
                              : 'Mark as Complete'),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  data['note'],
                  textAlign: TextAlign.justify,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 17.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
