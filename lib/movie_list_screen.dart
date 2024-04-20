import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final List<Movie> movieList = [];
  bool _showForm = false; // New state variable to track form visibility

  @override
  void initState() {
    super.initState();
    _getMovieList();
  }

  void _getMovieList() {
    _firebaseFirestore.collection('movies').get().then((value) {
      movieList.clear();
      for (QueryDocumentSnapshot doc in value.docs) {
        movieList.add(
          Movie.fromJson(doc.id, doc.data() as Map<String, dynamic>),
        );
      }
    });
  }

  void _toggleFormVisibility() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
      ),
      body: _showForm
          ? _buildForm() // Show form if _showForm is true
          : StreamBuilder(
          stream: _firebaseFirestore.collection('movies').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            movieList.clear();
            for (QueryDocumentSnapshot doc
            in (snapshot.data?.docs ?? [])) {
              movieList.add(
                Movie.fromJson(doc.id, doc.data() as Map<String, dynamic>),
              );
            }

            return ListView.separated(
              itemCount: movieList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(movieList[index].name),
                  subtitle: Row(
                    children: [
                      Text(movieList[index].languages),
                      const SizedBox(width: 10,),
                      Text("|  ${movieList[index].year}"),
                    ],
                  ),
                  leading: Text(movieList[index].rating),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline),
                              Text(' Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteMovie(movieList[index].id);
                        }
                      },
                    )
                );
              },
              separatorBuilder: (_, __) => const Divider(),
            );

          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFormVisibility, // Toggle form visibility on button press
        child: _showForm ? const Icon(Icons.close) : Icon(Icons.add),
      ),
    );
  }

  void _deleteMovie(String movieId) {
    _firebaseFirestore.collection('movies').doc(movieId).delete();
  }
  Widget _buildForm() {
    final nameController = TextEditingController();
    final yearController = TextEditingController();
    final languagesController = TextEditingController();
    final ratingController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Name'),
          ),
          TextFormField(
            controller: yearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Year'),
          ),
          TextFormField(
            controller: languagesController,
            decoration: InputDecoration(hintText: 'Languages'),
          ),
          TextFormField(
            controller: ratingController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Rating'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final newMovie = {
                'name': nameController.text,
                'year': yearController.text,
                'languages': languagesController.text,
                'rating': ratingController.text,
              };

              _firebaseFirestore.collection('movies').doc().set(newMovie);
              _toggleFormVisibility(); // Close the form after saving
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class Movie {
  final String id, name, languages, year, rating;

  Movie({
    required this.id,
    required this.name,
    required this.languages,
    required this.rating,
    required this.year,
  });

  factory Movie.fromJson(String id, Map<String, dynamic> json) {
    return Movie(
      id: id,
      name: json['name'],
      languages: json['languages'],
      rating: json['rating'] ?? 'Unknown',
      year: json['year'],
    );
  }
}
