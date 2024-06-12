import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTaskScreen extends StatefulWidget {
  final DocumentSnapshot taskDocument;

  const EditTaskScreen({Key? key, required this.taskDocument})
      : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController noteController;
  late TextEditingController titleController;
  late TextEditingController
      dateTimeController; // Controller for date and time input

  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.taskDocument['title']);
    noteController = TextEditingController(text: widget.taskDocument['note']);
    dateTimeController =
        TextEditingController(text: widget.taskDocument['dateTime']);
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    dateTimeController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3639),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 36, 39),
        title: const Text(
          'Edit Task',
          style: TextStyle(
            color: Color(0xFFDCD7C9),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFDCD7C9),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Task',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: dateTimeController,
                decoration: const InputDecoration(
                  hintText: 'Due Date',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    final TimeOfDay? timePicked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (timePicked != null) {
                      final DateTime selectedDateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        timePicked.hour,
                        timePicked.minute,
                      );
                      setState(() {
                        dateTimeController.text = selectedDateTime.toString();
                      });
                    }
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: noteController,
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await _firestore
                            .collection('tasks')
                            .doc(widget.taskDocument.id)
                            .update({
                          'title': titleController.text,
                          'note': noteController.text,
                          'dateTime': dateTimeController.text,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task updated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFFDCD7C9),
                    backgroundColor: const Color(0xFFA27B5C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
