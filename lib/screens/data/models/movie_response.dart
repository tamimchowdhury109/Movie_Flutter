class MovieResponse {
  final String id, name, languages, year, rating, imageUrl,coverImageUrl;

  MovieResponse({
    required this.id,
    required this.name,
    required this.languages,
    required this.rating,
    required this.year,
    required this.imageUrl,
    required this.coverImageUrl,
  });

  factory MovieResponse.fromJson(String id, Map<String, dynamic> json) {
    return MovieResponse(
      id: id,
      name: json['name'],
      languages: json['languages'],
      rating: json['rating'] ?? 'Unknown',
      year: json['year'],
      imageUrl: json['imageUrl'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
    );
  }
}
