import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/screens/data/models/movie_response.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final List<MovieResponse> movieList = [];
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
          MovieResponse.fromJson(doc.id, doc.data() as Map<String, dynamic>),
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
          ? _buildForm()
          : StreamBuilder(
          stream: _firebaseFirestore.collection('movies').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            movieList.clear();
            for (QueryDocumentSnapshot doc in (snapshot.data?.docs ?? [])) {
              movieList.add(
                MovieResponse.fromJson(
                    doc.id, doc.data() as Map<String, dynamic>),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration:
                    Duration(milliseconds: 800),
                    pauseAutoPlayOnTouch: true,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.8,
                  ),
                  items: movieList
                      .map((movie) => Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(
                            horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                          BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                movie.coverImageUrl ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ))
                      .toList(),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: movieList.length,
                      itemBuilder: (context, index) {
                        String imageUrl = movieList[index].imageUrl ?? '';
                        return GestureDetector(
                          onTap: () {
                            // Add your onTap logic here
                          },
                          child: Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/no_image.jpg',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                      : Image.asset(
                                    'assets/images/no_image.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    movieList[index].name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  child: Text("Top Movie",
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: movieList.length,
                    itemBuilder: (context, index) {
                      String imageUrl =
                          movieList[index].imageUrl ?? '';
                      return ListTile(
                        title: Text(movieList[index].name),
                        subtitle: Row(
                          children: [
                            Text("🔉 ${movieList[index].languages}"),
                            const SizedBox(
                              width: 10,
                            ),
                            Text("- 🕒 ${movieList[index].year}"),
                            const SizedBox(
                              width: 10,
                            ),
                            Text("- ⭐ ${movieList[index].rating}"),
                          ],
                        ),
                        leading: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error,
                              stackTrace) {
                            return Image.asset(
                              'assets/images/no_image.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : Image.asset(
                          'assets/images/no_image.jpg',
                          fit: BoxFit.cover,
                        ),
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
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(),
                  ),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFormVisibility,
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
    final imageController = TextEditingController();
    final coverImageUrlController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Name'),
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Enter movie name';
                  }
                  return null;
                },
              ),
        
              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Year'),
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Enter movie year';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: languagesController,
                decoration: InputDecoration(hintText: 'Languages'),
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Enter movie language';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ratingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Rating'),
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Enter movie rating';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: imageController,
                decoration: InputDecoration(hintText: 'Image Url'),
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Enter movie poster url';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: coverImageUrlController,
                decoration: InputDecoration(hintText: 'Cover Image Url'),
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Enter movie cover url';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newMovie = {
                      'name': nameController.text,
                      'year': yearController.text,
                      'languages': languagesController.text,
                      'rating': ratingController.text,
                      'imageUrl': imageController.text,
                      'coverImageUrl': imageController.text,
                    };
        
                    _firebaseFirestore.collection('movies').doc().set(newMovie);
                    _toggleFormVisibility(); // Close the form after saving
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
