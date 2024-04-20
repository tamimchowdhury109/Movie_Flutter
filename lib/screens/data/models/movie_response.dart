class MovieResponse {
  final String id, name, languages, year, rating;

  MovieResponse({
    required this.id,
    required this.name,
    required this.languages,
    required this.rating,
    required this.year,
  });

  factory MovieResponse.fromJson(String id, Map<String, dynamic> json) {
    return MovieResponse(
      id: id,
      name: json['name'],
      languages: json['languages'],
      rating: json['rating'] ?? 'Unknown',
      year: json['year'],
    );
  }
}
