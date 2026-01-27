import 'package:cloud_firestore/cloud_firestore.dart';

class Crud {
  final CollectionReference _movieCollections = FirebaseFirestore.instance
      .collection('movies');

  //create operation
  Future<void> addMovies(String name, String type, String ratings) async {
    await _movieCollections.add({
      'name': name,
      'type': type,
      'ratings': ratings,
    });
  }

  //read operation
  Stream<QuerySnapshot> get movies {
    return _movieCollections.orderBy('name', descending: true).snapshots();
  }

  // Edit a movie
  Future<void> updateMovie(
    String docId,
    String name,
    String type,
    String ratings,
  ) async {
    return await _movieCollections.doc(docId).update({
      'name': name,
      'type': type,
      'ratings': ratings,
    });
  }

  //delete operation
  Future<void> deleteMovie(String docId) async {
    return await _movieCollections.doc(docId).delete();
  }
}
