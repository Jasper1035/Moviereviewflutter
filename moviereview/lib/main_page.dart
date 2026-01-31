import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviereview/firebase/authentication_firebase.dart';
import 'package:moviereview/firebase/crud.dart';
import 'package:moviereview/registrationpage/sign_in.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _ratingsController = TextEditingController();
  final Crud _db = Crud();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Review'),
        actions: [
          IconButton(
            onPressed: () async {
              final AuthenticationFirebase authenticationFirebase =
                  AuthenticationFirebase();
              await authenticationFirebase.signOut();

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              }
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();

          return Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: DataTable(
                  showCheckboxColumn: false,
                  horizontalMargin: 20,
                  columnSpacing: 28,
                  border: TableBorder.all(width: 2),
                  headingRowColor: WidgetStateProperty.all(Color(0xff878787)),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Movie Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Movie Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Ratings',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  rows: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DataRow(
                      onSelectChanged: (bool? selected) {
                        if (selected != null && selected) {
                          _editFields(doc.id, data);
                        }
                      },
                      cells: [
                        DataCell(Text(data['name'] ?? '')),
                        DataCell(Text(data['type'] ?? '')),
                        DataCell(Text('${data['ratings'] ?? ''} /10')),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('movies')
                                  .doc(doc.id)
                                  .delete();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${data['name']} Deleted'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.large(
        onPressed: () => _addMoviesInList(context),
        backgroundColor: Color(0xff05ad98),
        foregroundColor: Color(0xffffffff),

        child: Icon(Icons.add),
      ),
    );
  }

  // add icon and alartdialog showup

  void _addMoviesInList(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Add new Movie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Movie Name'),
              ),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Movie Type'),
              ),
              TextField(
                controller: _ratingsController,
                decoration: InputDecoration(labelText: 'Ratings(e.g: 8.5)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? enteredRating = double.tryParse(
                  _ratingsController.text,
                );

                if (_nameController.text.isNotEmpty &&
                    enteredRating != null &&
                    _typeController.text.isNotEmpty) {
                  if (enteredRating >= 0 && enteredRating <= 10) {
                    _db.addMovies(
                      _nameController.text,
                      _typeController.text,
                      _ratingsController.text,
                    );

                    Navigator.pop(context);
                    _nameController.clear();
                    _typeController.clear();
                    _ratingsController.clear();
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Enter a Rating between 0 and 10'),
                      ),
                    );
                  }
                }
              },
              child: Text('Add Movie'),
            ),
          ],
        );
      },
    );
  }

  //movie edit option

  void _editFields(String docId, Map<String, dynamic> movie) {
    _nameController.text = movie['name'] ?? '';
    _typeController.text = movie['type'] ?? '';
    _ratingsController.text = movie['ratings'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit the Fields'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Movie name'),
              ),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Movie type'),
              ),
              TextField(
                controller: _ratingsController,
                decoration: InputDecoration(labelText: 'Ratings'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                double? enteredRating = double.tryParse(
                  _ratingsController.text,
                );
                if (_nameController.text.isNotEmpty &&
                    _typeController.text.isNotEmpty) {
                  if (enteredRating != null &&
                      enteredRating >= 0 &&
                      enteredRating <= 10) {
                    await FirebaseFirestore.instance
                        .collection('movies')
                        .doc(docId)
                        .update({
                          'name': _nameController.text,
                          'type': _typeController.text,
                          'ratings': _ratingsController.text,
                        });

                    Navigator.pop(context);
                  }
                }
              },
              child: Text('save changes'),
            ),
          ],
        );
      },
    );
  }
}
