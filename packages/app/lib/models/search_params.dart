class SearchParams {
  SearchParams({
    required this.city,
    required this.maxDistanceKm,
    this.level,
    Set<String>? instruments,
    Set<String>? genres,
    this.postType,
    this.availableFor,
    this.hasYoutube,
  })  : instruments = instruments ?? {},
        genres = genres ?? {};
  final String city;
  final String? level;
  final Set<String> instruments;
  final Set<String> genres;
  final double maxDistanceKm;
  final String? postType; // 'musician' ou 'band'
  final String? availableFor; // 'gig', 'rehearsal', etc.
  final bool? hasYoutube;

  SearchParams copyWith({
    String? city,
    String? level,
    Set<String>? instruments,
    Set<String>? genres,
    double? maxDistanceKm,
    String? postType,
    String? availableFor,
    bool? hasYoutube,
  }) {
    return SearchParams(
      city: city ?? this.city,
      level: level ?? this.level,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      postType: postType ?? this.postType,
      availableFor: availableFor ?? this.availableFor,
      hasYoutube: hasYoutube ?? this.hasYoutube,
    );
  }
}
